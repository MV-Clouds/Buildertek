public without sharing class QBPOResponseJSON {
    public PurchaseOrder PurchaseOrder;
		// public String time;
	public class VendorRef{
		public String value;
		public String name;
	}
	public class VendorAddr{
		public String Line3;
		public String Line4;
		public String Line2;
		public String Line1;
		public String Id;
	}
	public class TaxCodeRef{
		public String value;
	}
	public class ShipAddr{
		public String Line2;
		public String Id;
		public String Line3;
		public String Line1;
		public String Line4;
	}
	public class PurchaseOrder{
		public VendorRef VendorRef;
		public VendorAddr VendorAddr;
		public String POStatus;
		public String PrivateNote;
		public Boolean sparse;
		public ShipAddr ShipAddr;
		public String TxnDate;
		public Decimal TotalAmt;
		public CurrencyRef CurrencyRef;
		public list<Line> Line;
		public APAccountRef APAccountRef;
		public list<CustomField> CustomField;
		public String domain;
		public String Id;
		public String SyncToken;
		public MetaData MetaData;
		public String DocNumber;
	}
	public class ProjectRef{
		public String value;
	}
	public class MetaData{
		public String LastUpdatedTime;
		public String CreateTime;
	}
	public class Line{
		public Decimal Amount;
		public ItemBasedExpenseLineDetail ItemBasedExpenseLineDetail;
		public String Id;
		public ProjectRef ProjectRef;
		public String DetailType;
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

	public QueryResponse QueryResponse;
	public class QueryResponse{
		public Integer startPosition;
		public Integer maxResults;
		public list<PurchaseOrder> PurchaseOrder;
		public Integer totalCount;
	}

    public static QBPOResponseJSON parse(String json) {
		System.debug('in parse ');
		return (QBPOResponseJSON) System.JSON.deserialize(json, QBPOResponseJSON.class);
	}
}