public with sharing class QBExpenseJSON {
    public Boolean sparse;
    public String PaymentType;
    public String PrivateNote;
    public Date TxnDate;
    public Decimal TotalAmt;
    public PurchaseEx PurchaseEx;
    public AccountRef AccountRef;
    public list<String> CustomField;
    public list<Line> Line;
    public String Id;
    public String domain;
    public MetaData MetaData;
    public String SyncToken;
	public EntityRef EntityRef;
	public PaymentMethodRef PaymentMethodRef;
	public class value{
		public String Value;
		public String Name;
	}
	public class TaxCodeRef{
		public String value;
	}
	public class PurchaseEx{
		public list<any_y> any_y;
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
		public String DetailType;
		public ProjectRef ProjectRef;
		public AccountBasedExpenseLineDetail AccountBasedExpenseLineDetail;
		public ItemBasedExpenseLineDetail ItemBasedExpenseLineDetail;
		public String Description;
		public String Id;
	}
	public class any_y{
		public Boolean globalScope;
		public String declaredType;
		public value value;
		public String scope;
		public Boolean nil;
		public Boolean typeSubstituted;
		public String name;
	}
	public class AccountRef{
		public String name;
		// public String name;
		public String value;
		// public String value;
	}
	public class AccountBasedExpenseLineDetail{
		public TaxCodeRef TaxCodeRef;
		public String BillableStatus;
		public AccountRef AccountRef;
	}
	public class EntityRef{
		public String type;
		public String name;
		public String value;
	}
	public class ItemBasedExpenseLineDetail{
		public ItemRef ItemRef;
		public String BillableStatus;
		public Double UnitPrice;
		public TaxCodeRef TaxCodeRef;
		public Double Qty;
	}
	public class ItemRef{
		public String value;
		public String name;
	}
	public class PaymentMethodRef{
		public String value;
	}
}