public without sharing class QBBillReqJSON {
    
    public Boolean sparse;
		public String PrivateNote;
		public CurrencyRef CurrencyRef;
		public SalesTermRef SalesTermRef;
		public Decimal TotalAmt;
		public DepartmentRef DepartmentRef;
		public String TxnDate;
		public String DueDate;
		public VendorRef VendorRef;
		public list<Line> Line;
		public APAccountRef APAccountRef;
		public Decimal Balance;
		public String domain;
		public String Id;
		public String SyncToken;
		public MetaData MetaData;
		public String DocNumber;
	public class VendorRef{
		public String value;
		public String name;
	}
	public class TaxCodeRef{
		public String value;
	}
	public class SalesTermRef{
		public String value;
	}
	public class ProjectRef{
		public String value;
	}
	public class MetaData{
		public String CreateTime;
		public String LastUpdatedTime;
	}
	public class MarkupInfo{
		public Double Percent;
	}
	public class Line{
		public String DetailType;
		public Decimal Amount;
		public String Id;
		public ProjectRef ProjectRef;
		public AccountBasedExpenseLineDetail AccountBasedExpenseLineDetail;
		public ItemBasedExpenseLineDetail ItemBasedExpenseLineDetail;
		public String Description;
	}
	public class DepartmentRef{
		public String value;
		public String name;
	}
	public class CustomerRef{
		public String name;
		public String value;
	}
	public class CurrencyRef{
		public String value;
		public String name;
	}
	public class APAccountRef{
		public String value;
		public String name;
	}
	public class AccountRef{
		public String value;
		public String name;
	}
	public class AccountBasedExpenseLineDetail{
		public String BillableStatus;
		public CustomerRef CustomerRef;
		public AccountRef AccountRef;
		public MarkupInfo MarkupInfo;
		public TaxCodeRef TaxCodeRef;
	}
	public class ItemBasedExpenseLineDetail{
		public String BillableStatus;
		public Double UnitPrice;
		public ItemRef ItemRef;
		public Double Qty;
		public TaxCodeRef TaxCodeRef;
	}
	public class ItemRef{
		public String value;
		public String name;
	}

}