public with sharing class QBTermReqJSON {
    public Boolean sparse;
    public String Type;
    public Double DiscountDays;
    public Boolean Active;
    public Double DiscountPercent;
    public Double DueDays;
    public String Name;
    public String Id;
    public String domain;
    public MetaData MetaData;
    public String SyncToken;
    
    public class MetaData{
        public String LastUpdatedTime;
        public String CreateTime;
    }
}