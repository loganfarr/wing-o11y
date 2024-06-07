bring cloud; 
bring ex;
bring util;
bring math;

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
    this.api.post("/logs", this.intakeMessage);

    this.table = new ex.Table({
      name: "logs",
      primaryKey: "logId", 
      columns: {
        logId: ex.ColumnType.STRING, 
        accountId: ex.ColumnType.STRING,
        log: ex.ColumnType.JSON,
        timestamp: ex.ColumnType.NUMBER
      }
    });

    this.bucket = new cloud.Bucket();

    this.inboundTopic = new cloud.Topic();
    this.inboundQueue = new cloud.Queue();
    this.inboundTopic.subscribeQueue(this.inboundQueue);

    let processFunction = new cloud.Function(this.processMessage);

    this.outboundTopic = new cloud.Topic();
    this.outboundQueue = new cloud.Queue();
    this.outboundTopic.subscribeQueue(this.outboundQueue);
    
  }

  pub inflight generateId(length: num): str {
    let var result = "";
    let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    let charactersLength = characters.length;
    let var counter = 0;
    while (counter < length) {
      result += characters.at(math.floor(math.random() * charactersLength));
      counter += 1;
    }
    return result;
  }

  pub inflight intakeMessage(request: cloud.ApiRequest): cloud.ApiResponse { 
    if request.body == nil {
      return cloud.ApiResponse{
        status: 400, 
        body: "Empty log message"
      };
    }

    let var logMessage: str = request.body!;

    let logRecord: Json = {
      "message":logMessage, 
      "logId":this.generateId(16)
      // @todo add account ID from auth workflow
    };

    this.inboundTopic.publish(Json.stringify(logRecord));

    return cloud.ApiResponse{
      status: 200, 
      body: Json.stringify({})
    };
  }

  pub inflight processMessage(message:str?): str? {
    if message == nil {
      throw "Event received was empty";
    }

    log("Message received:");
    log(message!);
    
    let logObject = Json.parse(message!);

    // Process logic goes here


    // Log is finished processing

    this.outboundTopic.publish(message!);

    return "return value";
  }
}