public with sharing class QBPMCreateJSON {
    public String Type;
    public Boolean sparse;
    public Boolean Active;
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