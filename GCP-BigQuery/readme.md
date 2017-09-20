# LogRhythm Distribution Services into Google BigQuery

This folder contains example reference for setting up and sending LogRhythm MDI (Machine Data Intelligence) into Google BigQuery.


## LogStash Setup

Elastic's LogStash is used to convert LogRhythm's Key-Pair Value format into CSV, a mechanism to receive Syslog, write out LR MDI into time based and optionally perform further enrichment or filtering as required, e.g,. splitting the NormalMsgDate into DAY field.

## Google BigQuery Setup

Create a new Dataset, and within that create a new Table.  

The location should be Google Cloud Storage, gs://bucket/object* with a file format of CSV

Specify a Table name, and set the Table type to External.  External configures BigQuery to use the CSV files in GCP Storage.  The advantage of this approach is as newly added date is written it can be accessed; however, using other automated methods and date partition internal tables can also be used but that's beyond the scope of this example.

The Schema can be found in this repository.  Note, it's important that your LR Distribution Service be configured to send all metadata fields and in the default order, otherwise you'll need change this schema accordingly.

Finally, the field delimeter is a Comma and that's about that.  You're ready to create table and start using your LogRhythm MDI in GCP BigQuery.


```Account:STRING,Action:STRING,Aggregate:BOOLEAN,Amount:STRING,Archive:BOOLEAN,BytesIn:FLOAT,BytesOut:FLOAT,CollectionSequence:INTEGER,Command:STRING,CommonEventID:FLOAT,CVE:STRING,DateInserted:STRING,DHostID:INTEGER,DHostZone:INTEGER,DInterface:INTEGER,DIP:STRING,Direction:INTEGER,DLocationKey:STRING,DMAC:STRING,DName:STRING,DNameParsed:STRING,DNameResolved:STRING,DNATIP:STRING,DNATPort:FLOAT,DNetworkID:INTEGER,Domain:STRING,DomainOrigin:STRING,DPort:INTEGER,DropLog:BOOLEAN,DropRaw:BOOLEAN,Duration:INTEGER,EntityId:INTEGER,EventClassification:STRING,EventCommonEventID:FLOAT,FalseAlarmRating:INTEGER,Forward:BOOLEAN,ForwardToLogMart:BOOLEAN,GLPRAssignedRBP:INTEGER,Group:STRING,HasBeenInserted_EMDB:BOOLEAN,HasBeenQueued_Archiving:BOOLEAN,HasBeenQueued_EventProcessor:BOOLEAN,HasBeenQueued_LogProcessor:BOOLEAN,Hash:STRING,HostID:INTEGER,IgnoreGlobalRBPCriteria:BOOLEAN,IsDNameParsedValue:BOOLEAN,IsRemote:BOOLEAN,IsSNameParsedValue:STRING,ItemsIn:STRING,ItemsOut:STRING,Login:STRING,LogMartMode:INTEGER,MediatorMsgID:INTEGER,MediatorSessionID:INTEGER,MPERuleID:INTEGER,MsgClassID:INTEGER,MsgCount:INTEGER,MsgDate:STRING,MsgDateOrigin:STRING,MsgSourceHostID:FLOAT,MsgSourceID:FLOAT,NormalMsgDate:TIMESTAMP,Object:STRING,ObjectName:STRING,ObjectType:STRING,ParentProcessId:STRING,ParentProcessName:STRING,ParentProcessPath:STRING,PID:STRING,Policy:STRING,Priority:STRING,Process:STRING,ProtocolID:INTEGER,Quantity:INTEGER,Rate:FLOAT,Reason:STRING,Recipient:STRING,RecipientIdentity:STRING,RecipientIdentityCompany:STRING,RecipientIdentityDepartment:STRING,RecipientIdentityDomain:STRING,RecipientIdentityID:STRING,RecipientIdentityTitle:STRING,ResponseCode:STRING,Result:STRING,RiskRating:FLOAT,Sender:STRING,SenderIdentity:STRING,SenderIdentityCompany:STRING,SenderIdentityDepartment:STRING,SenderIdentityDomain:STRING,SenderIdentityID:INTEGER,SenderIdentityTitle:STRING,SerialNumber:STRING,ServiceID:INTEGER,Session:STRING,SessionType:STRING,Severity:STRING,SHostID:INTEGER,SHostZone:INTEGER,SInterface:STRING,SIP:STRING,Size:FLOAT,SLocationKey:STRING,SMAC:STRING,SName:STRING,SNameParsed:STRING,SNameResolved:STRING,SNATIP:STRING,SNATPort:INTEGER,SNetworkID:STRING,SPort:INTEGER,Status:STRING,Subject:STRING,SystemMonitorID:FLOAT,ThreatId:STRING,ThreatName:STRING,timestamp:STRING,UniqueID:STRING,URL:STRING,UserAgent:STRING,UserImpactedIdentity:STRING,UserImpactedIdentityCompany:STRING,UserImpactedIdentityDomain:STRING,UserImpactedIdentityID:INTEGER,UserImpactedIdentityTitle:STRING,UserOriginIdentity:STRING,UserOriginIdentityCompany:STRING,UserOriginIdentityDepartment:STRING,UserOriginIdentityDomain:STRING,UserOriginIdentityID:INTEGER,UserOriginIdentityTitle:STRING,VendorInfo:STRING,VendorMsgID:STRING,Version:STRING


