public with sharing class QBBillResponseJSON {
    public Bill Bill;
		// public String time;
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
		public Integer Percent;
	}
	public class Line{
		public ProjectRef ProjectRef;
		public String Description;
		public String DetailType;
		public String Id;
		public AccountBasedExpenseLineDetail AccountBasedExpenseLineDetail;
		public Decimal Amount;
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
	public class Bill{
		public Boolean sparse;
		public DepartmentRef DepartmentRef;
		public String DueDate;
		public SalesTermRef SalesTermRef;
		public Decimal TotalAmt;
		public CurrencyRef CurrencyRef;
		public String TxnDate;
		public String PrivateNote;
		public VendorRef VendorRef;
		public APAccountRef APAccountRef;
		public list<Line> Line;
		public Decimal Balance;
		public String domain;
		public String Id;
		public String SyncToken;
		public MetaData MetaData;
		public String DocNumber;
	}
	public class APAccountRef{
		public String value;
		public String name;
	}
	public class AccountRef{
		public String name;
		public String value;
	}
	public class AccountBasedExpenseLineDetail{
		public TaxCodeRef TaxCodeRef;
		public CustomerRef CustomerRef;
		public String BillableStatus;
		public MarkupInfo MarkupInfo;
		public AccountRef AccountRef;
	}

    public static QBBillResponseJSON parse(String json) {
		return (QBBillResponseJSON) System.JSON.deserialize(json, QBBillResponseJSON.class);
	}
}