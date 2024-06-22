bring cloud; 
bring cognito;
bring ex;
bring util;
bring math;

struct LogRecord {
  log: Json;
  logId: str; 
  accountId: str; 
  timestamp: num;
}

pub class LogsApi {
  api: cloud.Api;
  table: ex.Table;
  inboundTopic: cloud.Topic;
  inboundQueue: cloud.Queue;

  outboundTopic: cloud.Topic;
  outboundQueue: cloud.Queue;
  bucket: cloud.Bucket;
  
  new() {
    this.api = new cloud.Api();
    let auth = new cognito.Cognito(this.api);

    this.api.get("/", inflight (request: cloud.ApiRequest): cloud.ApiResponse => {
      return cloud.ApiResponse{
        status: 400, 
        body: "Not implemented"
      };
    });

    this.api.post("/logs", inflight (request: cloud.ApiRequest): cloud.ApiResponse => { 
      if request.body == nil {
        return cloud.ApiResponse{
          status: 400, 
          body: "Empty log message"
        };
      }
      
      let var logMessage = request.body;

      let logRecord: Json = {
        "log":logMessage, 
        "logId":this.generateId(16),
        "accountId":"123abcd", // @todo add account ID from auth workflow
        "timestamp": 12314512513
      };
  
      this.inboundTopic.publish(Json.stringify(logRecord));
  
      return cloud.ApiResponse{
        status: 200, 
        body: Json.stringify({})
      };
    });
    auth.post("/logs");

    this.api.get("/logs/:logId", inflight (request: cloud.ApiRequest): cloud.ApiResponse => {
      return cloud.ApiResponse{
        status: 400, 
        body: "Not implemented"
      };
    });

    this.table = new ex.Table({
      name: "logs",
      primaryKey: "logId", 
      columns: {
        logId: ex.ColumnType.STRING, 
        accountId: ex.ColumnType.STRING,
        log: ex.ColumnType.STRING,
        timestamp: ex.ColumnType.NUMBER
      }
    }) as "LogsTable";

    this.bucket = new cloud.Bucket() as "LogStorage";

    this.inboundTopic = new cloud.Topic() as "InboundTopic";
    this.inboundQueue = new cloud.Queue() as "InboundQueue";

    this.inboundTopic.subscribeQueue(this.inboundQueue);

    let processFunction = new cloud.Function(inflight (event: str?) => {
      this.processMessage(event);
    }) as "ProcessMessageFunction";

    this.inboundQueue.setConsumer(inflight (message: str?) => {
      this.processMessage(message);
    });
    
    this.outboundTopic = new cloud.Topic() as "OutboundTopic";
    this.outboundQueue = new cloud.Queue() as "OutboundQueue";
    this.outboundTopic.subscribeQueue(this.outboundQueue); 
    this.outboundQueue.setConsumer(inflight (message: str?) => {
      let var logRecord = LogRecord.fromJson(message);
      this.bucket.put(logRecord.logId, Json.stringify(logRecord));
    });
  }

  pub inflight generateId(length: num): str {
    let var result = "";
    let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    let charactersLength = characters.length;
    let var counter = 0;

    while (counter < length) {
      let randomIndex = math.floor(math.random() * charactersLength);
      result += characters.at(randomIndex);
      counter += 1;
    }

    return result;
  }

  pub inflight processMessage(body:str?): str? {
    if body == nil {
      throw "Event received was empty";
    }

    log("Message received:");
    log(body!);
    
    let var logRecord: LogRecord = LogRecord.fromJson(Json.parse(body!));

    // Process logic goes here


    // Log is finished processing

    this.table.insert(logRecord.logId, logRecord);

    this.outboundTopic.publish(Json.stringify(logRecord));

    return Json.stringify(this.table.get(logRecord.logId));
  }
  
  pub inflight getLogRecord(logId: str): LogRecord {
    return LogRecord.fromJson(this.table.get(logId));
  }
}