<#/*** 
1. Run this SQL script first, then export to CSV
2. Remove Classification Type from Classification, e.g., Security/Suspicious to Suspicious
3. Save as CSV (UTF8) 
***/

SELECT TOP (1000) [AIERuleID]
	  ,A.[Name] AS AIERuleName
      ,B.[Name] AS CommonEvent
	  ,B.CommonEventID AS CommonEventID
	  ,C.[FullName] AS Classification
	  ,C.MsgClassID AS MsgClassID
	  ,B.DefRiskRating AS RiskRating
  FROM [LogRhythmEMDB].[dbo].[AIERule] A
  INNER JOIN [dbo].[CommonEvent] B 
  ON A.CommonEventID = B.CommonEventID
  INNER JOIN [dbo].[MsgClass] C
  ON B.MsgClassID = C.MsgClassID
  WHERE AIERuleID < 1000000000

#>

#Update with your CSV path
$aie_csv_import = Import-CSV "C:\Temp\AIE Rules Export.csv"

#This increments per sub-rule
$MPERuleID = 1000000128

#Parent regex rule.  This shouldn't change.        
$MPERuleRegexID = 1000000042


function GenCommonEventXML($CommonEventID,$MsgClassID,$AIERuleName,$DefRiskRating){

$b = @("  <CommonEvent>
    <CommonEventID>$CommonEventID</CommonEventID>
    <MsgClassID>$MsgClassID</MsgClassID>
    <Name>$AIERuleName</Name>
    <ShortDesc />
    <DefRiskRating>$DefRiskRating</DefRiskRating>
    <DateUpdated>2017-12-07T14:48:27.31-08:00</DateUpdated>
    <RecordStatus>1</RecordStatus>
  </CommonEvent>")

  return $b

}

function GenMPEXML($MPERuleID,$MPERuleRegexID,$CommonEventID,$AIERuleName,$MsgClassID){

$a = @("<MPERule>
    <MPERuleID>$MPERuleID</MPERuleID>
    <MPERuleRegexID>$MPERuleRegexID</MPERuleRegexID>
    <RuleStatus>1</RuleStatus>
    <StatusName>Production</StatusName>
    <CommonEventID>$CommonEventID</CommonEventID>
    <CommonEventName>$AIERuleName</CommonEventName>
    <MsgClassID>$MsgClassID</MsgClassID>
    <Name>$AIERuleName</Name>
    <FullName>$AIERuleName</FullName>
    <BaseRule>0</BaseRule>
    <ShortDesc />
    <LongDesc />
    <DefMsgTTL>32</DefMsgTTL>
    <DefMsgArchiveMode>2</DefMsgArchiveMode>
    <DefMsgArchiveModeBool>true</DefMsgArchiveModeBool>
    <DefForwarding>1</DefForwarding>
    <DefForwardingBool>true</DefForwardingBool>
    <DefRiskRating>7</DefRiskRating>
    <DefFalseAlarmRating>0</DefFalseAlarmRating>
    <MapTag3>=$AIERuleName</MapTag3>
    <MapTag4>*</MapTag4>
    <InheritTech>1</InheritTech>
    <RecordStatus>1</RecordStatus>
    <DateUpdated>2018-02-21T22:16:48.16-08:00</DateUpdated>
    <SortOrder>1</SortOrder>
    <VersionMajor>4</VersionMajor>
    <VersionMinor>1</VersionMinor>
    <SHostIs>0</SHostIs>
    <DHostIs>0</DHostIs>
    <ServiceIs>0</ServiceIs>
    <HostContext>0</HostContext>
    <PrefixBaseRuleName>0</PrefixBaseRuleName>
    <IsSystemRule>No</IsSystemRule>
    <NewRuleRecordType>0</NewRuleRecordType>
    <MapVMID>*</MapVMID>
    <MapSName>*</MapSName>
    <MapDName>*</MapDName>
    <MapSPort>*</MapSPort>
    <MapDPort>*</MapDPort>
    <MapProtocolID>*</MapProtocolID>
    <MapLogin>*</MapLogin>
    <MapAccount>*</MapAccount>
    <MapGroup>*</MapGroup>
    <MapDomain>*</MapDomain>
    <MapSession>*</MapSession>
    <MapObject>*</MapObject>
    <MapURL>*</MapURL>
    <MapSender>*</MapSender>
    <MapRecipient>*</MapRecipient>
    <MapSubject>*</MapSubject>
    <MapBytesIn>*</MapBytesIn>
    <MapBytesOut>*</MapBytesOut>
    <MapItemsIn>*</MapItemsIn>
    <MapItemsOut>*</MapItemsOut>
    <MapAmount>*</MapAmount>
    <MapQuantity>*</MapQuantity>
    <MapRate>*</MapRate>
    <MapSize>*</MapSize>
    <DefLogMartMode>13627389</DefLogMartMode>
  </MPERule>")

  return $a

}

# Below will generate the <MPERule> and then the <CommonEvent> blocks
# You'll need manually copy and paste these into your LR MPE Export File

foreach($row in $aie_csv_import){

    $MPERuleID  = $MPERuleID  + 1

    $CommonEventID = $row.CommonEventID
    $AIERuleName = $row.AIERuleName
    $MsgClassID = $row.MsgClassID

    GenMPEXML $MPERuleID $MPERuleRegexID $CommonEventID $AIERuleName $MsgClassID

}

foreach($row in $aie_csv_import){

    $CommonEventID = $row.CommonEventID
    $AIERuleName = $row.AIERuleName
    $MsgClassID = $row.MsgClassID
    $DefRiskRating = $row.RiskRating

    GenCommonEventXML $CommonEventID $MsgClassID $AIERuleName $DefRiskRating

}
