public class QBInvoiceResponseJSON {
    public Invoice Invoice;
	public QueryResponse QueryResponse;

	public class TxnTaxDetail{
		public Double TotalTax;
	}
	public class TaxCodeRef{
		public String value;
	}
	public class ShipAddr{
		public String City;
		public String Line1;
		// public String Lat;
		// public String Long;
		public String PostalCode;
		public String CountrySubDivisionCode;
		public String Id;
	}
	public class SalesItemLineDetail{
		public ItemRef ItemRef;
		public TaxCodeRef TaxCodeRef;
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
		public SalesItemLineDetail SalesItemLineDetail;
		public String DetailType;
		// public Double Amount;
		public Double Amount;
		public Double LineNum;
	}
	public class ItemRef{
		public String value;
		public String name;
	}
	// public class LinkedTxn{
	// 	public String TxnId;
	// 	public String TxnType;
	// }
	public class Invoice{
		public String SyncToken;
		// public LinkedTxn LinkedTxn;
		public ShipAddr ShipAddr;
		public TxnTaxDetail TxnTaxDetail;
		public String EmailStatus;
		public CustomerRef CustomerRef;
		public Double Deposit;
		public Double Balance;
		public ProjectRef ProjectRef;
		public Boolean sparse;
		public String DocNumber;
		public BillAddr BillAddr;
		public Boolean ApplyTaxAfterDiscount;
		public MetaData MetaData;
		// public String DueDate;
		public Date DueDate;
		public Double TotalAmt;
		public list<Line> Line;
		public String PrintStatus;
		public list<CustomField> CustomField;
		public String domain;
		public String Id;
		public Date TxnDate;
	}
	public class CustomField{
		public String DefinitionId;
		public String Name;
		public String Type;
	}
	public class CustomerRef{
		public String name;
		public String value;
	}
	public class BillAddr{
		public String City;
		// public String Long;
		public String Lat;
		public String CountrySubDivisionCode;
		public String PostalCode;
		public String Id;
		public String Line1;
	}

	public class QueryResponse{
		public Integer startPosition;
		public Integer maxResults;
		public list<Invoice> Invoice;
		public Integer totalCount;
	}

    public static QBInvoiceResponseJSON parse(String json) {
		System.debug('in parse ');
		return (QBInvoiceResponseJSON) System.JSON.deserialize(json, QBInvoiceResponseJSON.class);
	}
}