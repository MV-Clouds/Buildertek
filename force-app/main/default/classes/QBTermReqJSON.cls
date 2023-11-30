public with sharing class QBTermReqJSON {
    public Boolean sparse;
    public String Type;
    public Integer DiscountDays;
    public Boolean Active;
    public Integer DiscountPercent;
    public Integer DueDays;
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