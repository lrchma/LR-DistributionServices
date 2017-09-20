# LogRhythm Distribution Services into Google BigQuery

** Please note, this is not official LogRhythm config or instructions, nor supported by LogRhythm. Use at own risk! **

This folder contains example reference for setting up and sending LogRhythm MDI (Machine Data Intelligence) into Google BigQuery.

```
LogRhythm MDI -> LDS over Syslog -> GCP Compute running LogStash -> CSV output in GCP Storage  -> Google BigQuery
```

## LogStash Setup

Elastic's LogStash is used to convert LogRhythm's Key-Pair Value format into CSV, a mechanism to receive Syslog, write out LR MDI into time based and optionally perform further enrichment or filtering as required, e.g,. splitting the NormalMsgDate into DAY field.

Install the LR-LDS template:
```curl -XPUT localhost:9200/_template/lr-lds-active -d@/tmp/lr-lds-template.json```

Logstash.conf
```input
{
    syslog
    {
       host => "0.0.0.0"
       port => 1514
       type => "logrhythm"
    }
}

filter {
 if [type] == "logrhythm" {

 grok {
  match => { "message" => '^%{GREEDYDATA:kvpairs} RawLog\=%{DATA:RawLog}$' }
  add_field => [ "received_at", "%{@timestamp}" ]
 }

  kv{
   source => "kvpairs"
   trim_value => '"'
   field_split => " "
   value_split => "="
  }

  prune {
    blacklist_names => [ "message" ]
    blacklist_names => [ "kvpairs" ]
  }
 }
}

output
{
    elasticsearch
    {
        hosts => ["127.0.0.1:9200"]
        index => "lr-lds-active-%{+YYYY.MM.dd}"
    }

csv {
     path => "/gcp/lr-lds/lr-lds-%{+YYYY-MM-dd}.log"
     #write_headers => true
     #headers => ["Account","Action","Aggregate","Amount","Archive","BytesIn","BytesOut","CollectionSequence","Command","CommonEventID","CVE","DateInserted","DHostID","DHostZone","DInterface","DIP","Direction","DLocationKey","DMAC","DName","DNameParsed","DNameResolved","DNATIP","DNATPort","DNetworkID","Domain","DomainOrigin","DPort","DropLog","DropRaw","Duration","EntityId","EventClassification","EventCommonEventID","FalseAlarmRating","Forward","ForwardToLogMart","GLPRAssignedRBP","Group","HasBeenInserted_EMDB","HasBeenQueued_Archiving","HasBeenQueued_EventProcessor","HasBeenQueued_LogProcessor","Hash","HostID","IgnoreGlobalRBPCriteria","IsDNameParsedValue","IsRemote","IsSNameParsedValue","ItemsIn","ItemsOut","Login","LogMartMode","MediatorMsgID","MediatorSessionID","MPERuleID","MsgClassID","MsgCount","MsgDate","MsgDateOrigin","MsgSourceHostID","MsgSourceID","NormalMsgDate","Object","ObjectName","ObjectType","ParentProcessId","ParentProcessName","ParentProcessPath","PID","Policy","Priority","Process","ProtocolID","Quantity","Rate","Reason","Recipient","RecipientIdentity","RecipientIdentityCompany","RecipientIdentityDepartment","RecipientIdentityDomain","RecipientIdentityID","RecipientIdentityTitle","ResponseCode","Result","RiskRating","Sender","SenderIdentity","SenderIdentityCompany","SenderIdentityDepartment","SenderIdentityDomain","SenderIdentityID","SenderIdentityTitle","SerialNumber","ServiceID","Session","SessionType","Severity","SHostID","SHostZone","SInterface","SIP","Size","SLocationKey","SMAC","SName","SNameParsed","SNameResolved","SNATIP","SNATPort","SNetworkID","SPort","Status","Subject","SystemMonitorID","ThreatId","ThreatName","timestamp","UniqueID","URL","UserAgent","UserImpactedIdentity","UserImpactedIdentityCompany","UserImpactedIdentityDomain","UserImpactedIdentityID","UserImpactedIdentityTitle","UserOriginIdentity","UserOriginIdentityCompany","UserOriginIdentityDepartment","UserOriginIdentityDomain","UserOriginIdentityID","UserOriginIdentityTitle","VendorInfo","VendorMsgID","Version"]
     fields => ["Account","Action","Aggregate","Amount","Archive","BytesIn","BytesOut","CollectionSequence","Command","CommonEventID","CVE","DateInserted","DHostID","DHostZone","DInterface","DIP","Direction","DLocationKey","DMAC","DName","DNameParsed","DNameResolved","DNATIP","DNATPort","DNetworkID","Domain","DomainOrigin","DPort","DropLog","DropRaw","Duration","EntityId","EventClassification","EventCommonEventID","FalseAlarmRating","Forward","ForwardToLogMart","GLPRAssignedRBP","Group","HasBeenInserted_EMDB","HasBeenQueued_Archiving","HasBeenQueued_EventProcessor","HasBeenQueued_LogProcessor","Hash","HostID","IgnoreGlobalRBPCriteria","IsDNameParsedValue","IsRemote","IsSNameParsedValue","ItemsIn","ItemsOut","Login","LogMartMode","MediatorMsgID","MediatorSessionID","MPERuleID","MsgClassID","MsgCount","MsgDate","MsgDateOrigin","MsgSourceHostID","MsgSourceID","NormalMsgDate","Object","ObjectName","ObjectType","ParentProcessId","ParentProcessName","ParentProcessPath","PID","Policy","Priority","Process","ProtocolID","Quantity","Rate","Reason","Recipient","RecipientIdentity","RecipientIdentityCompany","RecipientIdentityDepartment","RecipientIdentityDomain","RecipientIdentityID","RecipientIdentityTitle","ResponseCode","Result","RiskRating","Sender","SenderIdentity","SenderIdentityCompany","SenderIdentityDepartment","SenderIdentityDomain","SenderIdentityID","SenderIdentityTitle","SerialNumber","ServiceID","Session","SessionType","Severity","SHostID","SHostZone","SInterface","SIP","Size","SLocationKey","SMAC","SName","SNameParsed","SNameResolved","SNATIP","SNATPort","SNetworkID","SPort","Status","Subject","SystemMonitorID","ThreatId","ThreatName","timestamp","UniqueID","URL","UserAgent","UserImpactedIdentity","UserImpactedIdentityCompany","UserImpactedIdentityDomain","UserImpactedIdentityID","UserImpactedIdentityTitle","UserOriginIdentity","UserOriginIdentityCompany","UserOriginIdentityDepartment","UserOriginIdentityDomain","UserOriginIdentityID","UserOriginIdentityTitle","VendorInfo","VendorMsgID","Version"]
    }

    stdout { codec => rubydebug }
           
}
```

Note, if you don't have the appropriate LogStash plugins installed, you may need add them as follows:
```/opt/bitnami/logstash# ./bin/logstash-plugin install logstash-filter-prune```


### Google FUSE Setup
One method to easily get data into GCP Storage is using Google FUSE.

https://github.com/GoogleCloudPlatform/gcsfuse/blob/master/docs/installing.md


## Google BigQuery Setup

Create a new Dataset, and within that create a new Table.  

The location should be Google Cloud Storage, gs://bucket/object* with a file format of CSV

Specify a Table name, and set the Table type to External.  External configures BigQuery to use the CSV files in GCP Storage.  The advantage of this approach is as newly added date is written it can be accessed; however, using other automated methods and date partition internal tables can also be used but that's beyond the scope of this example.

The Schema can be found in this repository.  Note, it's important that your LR Distribution Service be configured to send all metadata fields and in the default order, otherwise you'll need change this schema accordingly.

Finally, the field delimeter is a Comma and that's about that.  You're ready to create table and start using your LogRhythm MDI in GCP BigQuery.


```Account:STRING,Action:STRING,Aggregate:BOOLEAN,Amount:STRING,Archive:BOOLEAN,BytesIn:FLOAT,BytesOut:FLOAT,CollectionSequence:INTEGER,Command:STRING,CommonEventID:FLOAT,CVE:STRING,DateInserted:STRING,DHostID:INTEGER,DHostZone:INTEGER,DInterface:INTEGER,DIP:STRING,Direction:INTEGER,DLocationKey:STRING,DMAC:STRING,DName:STRING,DNameParsed:STRING,DNameResolved:STRING,DNATIP:STRING,DNATPort:FLOAT,DNetworkID:INTEGER,Domain:STRING,DomainOrigin:STRING,DPort:INTEGER,DropLog:BOOLEAN,DropRaw:BOOLEAN,Duration:INTEGER,EntityId:INTEGER,EventClassification:STRING,EventCommonEventID:FLOAT,FalseAlarmRating:INTEGER,Forward:BOOLEAN,ForwardToLogMart:BOOLEAN,GLPRAssignedRBP:INTEGER,Group:STRING,HasBeenInserted_EMDB:BOOLEAN,HasBeenQueued_Archiving:BOOLEAN,HasBeenQueued_EventProcessor:BOOLEAN,HasBeenQueued_LogProcessor:BOOLEAN,Hash:STRING,HostID:INTEGER,IgnoreGlobalRBPCriteria:BOOLEAN,IsDNameParsedValue:BOOLEAN,IsRemote:BOOLEAN,IsSNameParsedValue:STRING,ItemsIn:STRING,ItemsOut:STRING,Login:STRING,LogMartMode:INTEGER,MediatorMsgID:INTEGER,MediatorSessionID:INTEGER,MPERuleID:INTEGER,MsgClassID:INTEGER,MsgCount:INTEGER,MsgDate:STRING,MsgDateOrigin:STRING,MsgSourceHostID:FLOAT,MsgSourceID:FLOAT,NormalMsgDate:TIMESTAMP,Object:STRING,ObjectName:STRING,ObjectType:STRING,ParentProcessId:STRING,ParentProcessName:STRING,ParentProcessPath:STRING,PID:STRING,Policy:STRING,Priority:STRING,Process:STRING,ProtocolID:INTEGER,Quantity:INTEGER,Rate:FLOAT,Reason:STRING,Recipient:STRING,RecipientIdentity:STRING,RecipientIdentityCompany:STRING,RecipientIdentityDepartment:STRING,RecipientIdentityDomain:STRING,RecipientIdentityID:STRING,RecipientIdentityTitle:STRING,ResponseCode:STRING,Result:STRING,RiskRating:FLOAT,Sender:STRING,SenderIdentity:STRING,SenderIdentityCompany:STRING,SenderIdentityDepartment:STRING,SenderIdentityDomain:STRING,SenderIdentityID:INTEGER,SenderIdentityTitle:STRING,SerialNumber:STRING,ServiceID:INTEGER,Session:STRING,SessionType:STRING,Severity:STRING,SHostID:INTEGER,SHostZone:INTEGER,SInterface:STRING,SIP:STRING,Size:FLOAT,SLocationKey:STRING,SMAC:STRING,SName:STRING,SNameParsed:STRING,SNameResolved:STRING,SNATIP:STRING,SNATPort:INTEGER,SNetworkID:STRING,SPort:INTEGER,Status:STRING,Subject:STRING,SystemMonitorID:FLOAT,ThreatId:STRING,ThreatName:STRING,timestamp:STRING,UniqueID:STRING,URL:STRING,UserAgent:STRING,UserImpactedIdentity:STRING,UserImpactedIdentityCompany:STRING,UserImpactedIdentityDomain:STRING,UserImpactedIdentityID:INTEGER,UserImpactedIdentityTitle:STRING,UserOriginIdentity:STRING,UserOriginIdentityCompany:STRING,UserOriginIdentityDepartment:STRING,UserOriginIdentityDomain:STRING,UserOriginIdentityID:INTEGER,UserOriginIdentityTitle:STRING,VendorInfo:STRING,VendorMsgID:STRING,Version:STRING```


