> hadoop2.7.2 MapReduce Job提交源码及切片源码分析

> 1. 首先从`waitForCompletion`函数进入

```java
boolean result = job.waitForCompletion(true);
```

```java
/**
   * Submit the job to the cluster and wait for it to finish.
   * @param verbose print the progress to the user
   * @return true if the job succeeded
   * @throws IOException thrown if the communication with the 
   *         <code>JobTracker</code> is lost
   */
  public boolean waitForCompletion(boolean verbose
                                   ) throws IOException, InterruptedException,
                                            ClassNotFoundException {
    // 首先判断state，当state为DEFINE时可以提交，进入 submit() 方法
    if (state == JobState.DEFINE) {
      submit();
    }
    if (verbose) {
      monitorAndPrintJob();
    } else {
      // get the completion poll interval from the client.
      int completionPollIntervalMillis = 
        Job.getCompletionPollInterval(cluster.getConf());
      while (!isComplete()) {
        try {
          Thread.sleep(completionPollIntervalMillis);
        } catch (InterruptedException ie) {
        }
      }
    }
    return isSuccessful();
  }
```

> 2. 进入`submit()`方法

```java
/**
   * Submit the job to the cluster and return immediately.
   * @throws IOException
   */
  public void submit() 
         throws IOException, InterruptedException, ClassNotFoundException {
    // 确认JobState状态为可提交状态，否则不能提交
    ensureState(JobState.DEFINE);
    // 设置使用最新的API
    setUseNewAPI();
    // 进入connect()方法，MapReduce作业提交时连接集群是通过Job类的connect()方法实现的，
    // 它实际上是构造集群Cluster实例cluster
    connect();
    // connect()方法执行完之后，定义提交者submitter
    final JobSubmitter submitter = 
        getJobSubmitter(cluster.getFileSystem(), cluster.getClient());
    status = ugi.doAs(new PrivilegedExceptionAction<JobStatus>() {
      public JobStatus run() throws IOException, InterruptedException, 
      ClassNotFoundException {
        // 这里的核心方法是submitJobInternal(),顾名思义，提交job的内部方法，实现了提交job的所有业务逻辑
          // 进入submitJobInternal
        return submitter.submitJobInternal(Job.this, cluster);
      }
    });
    // 提交之后state状态改变
    state = JobState.RUNNING;
    LOG.info("The url to track the job: " + getTrackingURL());
   }
```

> 3. 进入`connect()`方法

* MapReduce作业提交时连接集群通过Job的Connect方法实现，它实际上是构造集群Cluster实例cluster
* cluster是连接MapReduce集群的一种工具，提供了获取MapReduce集群信息的方法
* 在Cluster内部，有一个与集群进行通信的客户端通信协议ClientProtocol的实例client，它由ClientProtocolProvider的静态create()方法构造
* 在create内部，Hadoop2.x中提供了两种模式的ClientProtocol，分别为Yarn模式的YARNRunner和Local模式的LocalJobRunner，Cluster实际上是由它们负责与集群进行通信的

```java
  private synchronized void connect()
          throws IOException, InterruptedException, ClassNotFoundException {
    if (cluster == null) {// cluster提供了远程获取MapReduce的方法
      cluster = 
        ugi.doAs(new PrivilegedExceptionAction<Cluster>() {
                   public Cluster run()
                          throws IOException, InterruptedException, 
                                 ClassNotFoundException {
                     // 只需关注这个Cluster()构造器，构造集群cluster实例
                     return new Cluster(getConfiguration());
                   }
                 });
    }
  }
```

> 4. 进入`Cluster()`构造器

```java
// 首先调用一个参数的构造器，间接调用两个参数的构造器
public Cluster(Configuration conf) throws IOException {
    this(null, conf);
  }

  public Cluster(InetSocketAddress jobTrackAddr, Configuration conf) 
      throws IOException {
    this.conf = conf;
    this.ugi = UserGroupInformation.getCurrentUser();
    // 最重要的initialize方法
    initialize(jobTrackAddr, conf);
  }
  
// cluster中要关注的两个成员变量是客户端通讯协议提供者ClientProtocolProvider和客户端通讯协议ClientProtocol实例client
  private void initialize(InetSocketAddress jobTrackAddr, Configuration conf)
      throws IOException {

    synchronized (frameworkLoader) {
      for (ClientProtocolProvider provider : frameworkLoader) {
        LOG.debug("Trying ClientProtocolProvider : "
            + provider.getClass().getName());
        ClientProtocol clientProtocol = null; 
        try {
          // 如果配置文件没有配置YARN信息，则构建LocalRunner,MR任务本地运行
          // 如果配置文件有配置YARN信息，则构建YarnRunner,MR任务在YARN集群上运行
          if (jobTrackAddr == null) {
            // 客户端通讯协议client是调用ClientProtocolProvider的create()方法实现
            clientProtocol = provider.create(conf);
          } else {
            clientProtocol = provider.create(jobTrackAddr, conf);
          }

          if (clientProtocol != null) {
            clientProtocolProvider = provider;
            client = clientProtocol;
            LOG.debug("Picked " + provider.getClass().getName()
                + " as the ClientProtocolProvider");
            break;
          }
          else {
            LOG.debug("Cannot pick " + provider.getClass().getName()
                + " as the ClientProtocolProvider - returned null protocol");
          }
        } 
        catch (Exception e) {
          LOG.info("Failed to use " + provider.getClass().getName()
              + " due to error: ", e);
        }
      }
    }

    if (null == clientProtocolProvider || null == client) {
      throw new IOException(
          "Cannot initialize Cluster. Please check your configuration for "
              + MRConfig.FRAMEWORK_NAME
              + " and the correspond server addresses.");
    }
  }

```

> 5. 进入`submitJobInternal()`，job的内部提交方法，用于提交job到集群

```java
JobStatus submitJobInternal(Job job, Cluster cluster) 
  throws ClassNotFoundException, InterruptedException, IOException {

    //validate the jobs output specs 
    // 检查结果的输出路径是否已经存在，如果存在会报异常
    checkSpecs(job);

    // conf里边是集群的xml配置文件信息
    Configuration conf = job.getConfiguration();
    // 添加MR框架到分布式缓存中
    addMRFrameworkToDistributedCache(conf);

    // 获取提交执行时相关资源的临时存放路径
    // 参数未配置时默认是（工作空间根目录下的）/tmp/hadoop-yarn/staging/提交作业用户名/.staging
    Path jobStagingArea = JobSubmissionFiles.getStagingDir(cluster, conf);
    //configure the command line options correctly on the submitting dfs
    InetAddress ip = InetAddress.getLocalHost();
    if (ip != null) {//记录提交作业的主机IP、主机名，并且设置配置信息conf
      submitHostAddress = ip.getHostAddress();
      submitHostName = ip.getHostName();
      conf.set(MRJobConfig.JOB_SUBMITHOST,submitHostName);
      conf.set(MRJobConfig.JOB_SUBMITHOSTADDR,submitHostAddress);
    }
    // 获取JobId
    JobID jobId = submitClient.getNewJobID();
    // 设置jobId
    job.setJobID(jobId);
    // 提交作业的路径Path(Path parent, String child)，会将两个参数拼接为一个路径
    Path submitJobDir = new Path(jobStagingArea, jobId.toString());
    // job的状态
    JobStatus status = null;
    try {
      conf.set(MRJobConfig.USER_NAME,
          UserGroupInformation.getCurrentUser().getShortUserName());
      conf.set("hadoop.http.filter.initializers", 
          "org.apache.hadoop.yarn.server.webproxy.amfilter.AmFilterInitializer");
      conf.set(MRJobConfig.MAPREDUCE_JOB_DIR, submitJobDir.toString());
      LOG.debug("Configuring job " + jobId + " with " + submitJobDir 
          + " as the submit dir");
      // get delegation token for the dir
      TokenCache.obtainTokensForNamenodes(job.getCredentials(),
          new Path[] { submitJobDir }, conf);
      
      populateTokenCache(conf, job.getCredentials());

      // generate a secret to authenticate shuffle transfers
      if (TokenCache.getShuffleSecretKey(job.getCredentials()) == null) {
        KeyGenerator keyGen;
        try {
          keyGen = KeyGenerator.getInstance(SHUFFLE_KEYGEN_ALGORITHM);
          keyGen.init(SHUFFLE_KEY_LENGTH);
        } catch (NoSuchAlgorithmException e) {
          throw new IOException("Error generating shuffle secret key", e);
        }
        SecretKey shuffleKey = keyGen.generateKey();
        TokenCache.setShuffleSecretKey(shuffleKey.getEncoded(),
            job.getCredentials());
      }
      if (CryptoUtils.isEncryptedSpillEnabled(conf)) {
        conf.setInt(MRJobConfig.MR_AM_MAX_ATTEMPTS, 1);
        LOG.warn("Max job attempts set to 1 since encrypted intermediate" +
                "data spill is enabled");
      }

      // 拷贝jar包到集群
      // 此方法中调用如下方法：rUploader.uploadFiles(job, jobSubmitDir);
      // uploadFiles方法将jar包拷贝到集群
      copyAndConfigureFiles(job, submitJobDir);

      Path submitJobFile = JobSubmissionFiles.getJobConfPath(submitJobDir);
      
      // Create the splits for the job
      LOG.debug("Creating splits at " + jtFs.makeQualified(submitJobDir));
      // 计算切片，生成切片规划文件
      int maps = writeSplits(job, submitJobDir);
      conf.setInt(MRJobConfig.NUM_MAPS, maps);
      LOG.info("number of splits:" + maps);

      // write "queue admins of the queue to which job is being submitted"
      // to job file.
      String queue = conf.get(MRJobConfig.QUEUE_NAME,
          JobConf.DEFAULT_QUEUE_NAME);
      AccessControlList acl = submitClient.getQueueAdmins(queue);
      conf.set(toFullPropertyName(queue,
          QueueACL.ADMINISTER_JOBS.getAclName()), acl.getAclString());

      // removing jobtoken referrals before copying the jobconf to HDFS
      // as the tasks don't need this setting, actually they may break
      // because of it if present as the referral will point to a
      // different job.
      TokenCache.cleanUpTokenReferral(conf);

      if (conf.getBoolean(
          MRJobConfig.JOB_TOKEN_TRACKING_IDS_ENABLED,
          MRJobConfig.DEFAULT_JOB_TOKEN_TRACKING_IDS_ENABLED)) {
        // Add HDFS tracking ids
        ArrayList<String> trackingIds = new ArrayList<String>();
        for (Token<? extends TokenIdentifier> t :
            job.getCredentials().getAllTokens()) {
          trackingIds.add(t.decodeIdentifier().getTrackingId());
        }
        conf.setStrings(MRJobConfig.JOB_TOKEN_TRACKING_IDS,
            trackingIds.toArray(new String[trackingIds.size()]));
      }

      // Set reservation info if it exists
      ReservationId reservationId = job.getReservationId();
      if (reservationId != null) {
        conf.set(MRJobConfig.RESERVATION_ID, reservationId.toString());
      }

      // Write job file to submit dir
      writeConf(conf, submitJobFile);
      
      //
      // Now, actually submit the job (using the submit name)
      // 开始正式提交job
      printTokens(jobId, job.getCredentials());
      status = submitClient.submitJob(
          jobId, submitJobDir.toString(), job.getCredentials());
      if (status != null) {
        return status;
      } else {
        throw new IOException("Could not launch job");
      }
    } finally {
      if (status == null) {
        LOG.info("Cleaning up the staging area " + submitJobDir);
        if (jtFs != null && submitJobDir != null)
          jtFs.delete(submitJobDir, true);

      }
    }
  }
```

> 6. 进入`writeSplits(job, submitJobDir)`，计算切片，生成切片规划文件

* 内部会调用`writeNewSplits(job, jobSubmitDir)`方法
* `writeNewSplits(job, jobSubmitDir)`内部定义了一个`InputFormat`类型的实例input
* **InputFormat主要作用**：
  * 验证job的输入规范
  * 对输入的文件进行切分，形成多个InputSplit（切片）文件，每一个InputSplit对应着一个map任务（MapTask）
  * 将切片后的数据按照规则形成key，value键值对RecordReader

* input调用getSplits（）方法：`List<InputSplit> splits = input.getSplits(job);`

> 7. 进入**FileInputFormat**类下的`getSplits(job)`方法

```java
/** 
   * Generate the list of files and make them into FileSplits.
   * @param job the job context
   * @throws IOException
   */
  public List<InputSplit> getSplits(JobContext job) throws IOException {
    StopWatch sw = new StopWatch().start();
      
    // getFormatMinSplitSize()返回值固定为1，getMinSplitSize(job)返回job大小
    long minSize = Math.max(getFormatMinSplitSize(), getMinSplitSize(job));
    // getMaxSplitSize(job)返回Lang类型的最大值
    long maxSize = getMaxSplitSize(job);

    // generate splits 生成切片
    List<InputSplit> splits = new ArrayList<InputSplit>();
    List<FileStatus> files = listStatus(job);
    // 遍历job下的所有文件
    for (FileStatus file: files) {
      // 获取文件路径
      Path path = file.getPath();
      // 获取文件大小
      long length = file.getLen();
      if (length != 0) {
        BlockLocation[] blkLocations;
        if (file instanceof LocatedFileStatus) {
          blkLocations = ((LocatedFileStatus) file).getBlockLocations();
        } else {
          FileSystem fs = path.getFileSystem(job.getConfiguration());
          blkLocations = fs.getFileBlockLocations(file, 0, length);
        }
        // 判断是否可分割
        if (isSplitable(job, path)) {
          // 获取块大小
          // 本地环境块大小默认为32MB，YARN环境在hadoop2.x新版本为128MB，旧版本为64MB
          long blockSize = file.getBlockSize();
          // 计算切片的逻辑大小，默认等于块大小
          // 返回值为：return Math.max(minSize, Math.min(maxSize, blockSize));
          // 其中minSize=1， maxSize=Long类型最大值， blockSize为切片大小
          long splitSize = computeSplitSize(blockSize, minSize, maxSize);

          long bytesRemaining = length;
          // 每次切片时就要判断切片剩下的部分是否大于切片大小的SPLIT_SLOP（默认为1.1）倍，
          // 否则就不再切分，划为一块
          while (((double) bytesRemaining)/splitSize > SPLIT_SLOP) {
            int blkIndex = getBlockIndex(blkLocations, length-bytesRemaining);
            splits.add(makeSplit(path, length-bytesRemaining, splitSize,
                        blkLocations[blkIndex].getHosts(),
                        blkLocations[blkIndex].getCachedHosts()));
            bytesRemaining -= splitSize;
          }

          if (bytesRemaining != 0) {
            int blkIndex = getBlockIndex(blkLocations, length-bytesRemaining);
            splits.add(makeSplit(path, length-bytesRemaining, bytesRemaining,
                       blkLocations[blkIndex].getHosts(),
                       blkLocations[blkIndex].getCachedHosts()));
          }
        } else { // not splitable
          splits.add(makeSplit(path, 0, length, blkLocations[0].getHosts(),
                      blkLocations[0].getCachedHosts()));
        }
      } else { 
        //Create empty hosts array for zero length files
        splits.add(makeSplit(path, 0, length, new String[0]));
      }
    }
    // Save the number of input files for metrics/loadgen
    job.getConfiguration().setLong(NUM_INPUT_FILES, files.size());
    sw.stop();
    if (LOG.isDebugEnabled()) {
      LOG.debug("Total # of splits generated by getSplits: " + splits.size()
          + ", TimeTaken: " + sw.now(TimeUnit.MILLISECONDS));
    }
    return splits;
  }
```

