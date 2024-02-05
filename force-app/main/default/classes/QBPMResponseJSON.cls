public with sharing class QBPMResponseJSON {
    public PaymentMethod PaymentMethod;
	// public String time;
	public class PaymentMethod{
		public String Id;
		public String Type;
		public Boolean sparse;
		public String Name;
		public Boolean Active;
		public String domain;
		public MetaData MetaData;
		public String SyncToken;
	}
	public class MetaData{
		public String CreateTime;
		public String LastUpdatedTime;
	}
    public static QBPMResponseJSON parse(String json) {
		return (QBPMResponseJSON) System.JSON.deserialize(json, QBPMResponseJSON.class);
	}
}