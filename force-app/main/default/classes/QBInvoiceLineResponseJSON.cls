public class QBInvoiceLineResponseJSON {

    public Item Item;
	// public String time;
	public class ParentRef{
		public String value;
		public String name;
	}
	public class MetaData{
		public String LastUpdatedTime;
		public String CreateTime;
	}
	public class Item{
		public Boolean Active;
		public Boolean SubItem;
		public ParentRef ParentRef;
		public Boolean sparse;
		public String SyncToken;
		public Double Level;
		public String Type;
		public String Name;
		public String Id;
		public String domain;
		public MetaData MetaData;
		public String FullyQualifiedName;
	}

    public static QBInvoiceLineResponseJSON parse(String responseBody) {
        QBInvoiceLineResponseJSON ILR = (QBInvoiceLineResponseJSON) JSON.deserialize(responseBody, QBInvoiceLineResponseJSON.class);
        return ILR;
    }
    }