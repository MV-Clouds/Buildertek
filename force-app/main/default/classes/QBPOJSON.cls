public with sharing class QBPOJSON {
        public String PrivateNote;
		public ShipAddr ShipAddr;
		public String Id;
		public Decimal TotalAmt;
		public String POStatus;
		public String TxnDate;
		public String domain;
		public Boolean sparse;
		public VendorRef VendorRef;
		public CurrencyRef CurrencyRef;
		public list<Line> Line;
		public APAccountRef APAccountRef;
		public list<CustomField> CustomField;
		public POEmail POEmail;
		public VendorAddr VendorAddr;
		public String SyncToken;
		public MetaData MetaData;
		public String DocNumber;
	public class VendorRef{
		public String value;
		public String name;
	}
	public class VendorAddr{
		public String Id;
		public String Line1;
		public String Line3;
		public String Line2;
		public String Line4;
	}
	public class TaxCodeRef{
		public String value;
	}
	public class ShipAddr{
		public String Id;
		public String Line1;
		public String Line3;
		public String Line2;
		public String Line4;
	}
	public class ProjectRef{
		public String value;
	}
	public class POEmail{
		public String Address;
	}
	public class MetaData{
		public String CreateTime;
		public String LastUpdatedTime;
	}
	public class Line{
		public ProjectRef ProjectRef;
		public Decimal Amount;
		public String Id;
		public String DetailType;
		public ItemBasedExpenseLineDetail ItemBasedExpenseLineDetail;
	}
	public class ItemRef{
		public String name;
		public String value;
	}
	public class ItemBasedExpenseLineDetail{
		public CustomerRef CustomerRef;
		public Double Qty;
		public Double UnitPrice;
		public TaxCodeRef TaxCodeRef;
		public String BillableStatus;
		public ItemRef ItemRef;
	}
	public class CustomField{
		public String DefinitionId;
		public String Name;
		public String Type;
	}
	public class CustomerRef{
		public String value;
		public String name;
	}
	public class CurrencyRef{
		public String name;
		public String value;
	}
	public class APAccountRef{
		public String value;
		public String name;
	}
}