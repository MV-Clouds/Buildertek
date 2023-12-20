public with sharing class QBExpenseResponseJSON {
    public Purchase Purchase;
	// public String time;
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
	public class Purchase{
		public String PrivateNote;
		public Boolean sparse;
		public String PaymentType;
		public list<Line> Line;
		public Decimal TotalAmt;
		public AccountRef AccountRef;
		public String TxnDate;
		public list<String> CustomField;
		public PurchaseEx PurchaseEx;
		public String Id;
		public String domain;
		public MetaData MetaData;
		public String SyncToken;
	}
	public class ProjectRef{
		public String value;
	}
	public class MetaData{
		public String LastUpdatedTime;
		public String CreateTime;
	}
	public class Line{
		public String Id;
		public Decimal Amount;
		public ProjectRef ProjectRef;
		public String DetailType;
		public AccountBasedExpenseLineDetail AccountBasedExpenseLineDetail;
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

	public QueryResponse QueryResponse;
	public class QueryResponse{
		public Integer startPosition;
		public Integer maxResults;
		public list<Purchase> Purchase;
		public Integer totalCount;
	}

    public static QBExpenseResponseJSON parse(String json) {
		return (QBExpenseResponseJSON) System.JSON.deserialize(json, QBExpenseResponseJSON.class);
	}
}