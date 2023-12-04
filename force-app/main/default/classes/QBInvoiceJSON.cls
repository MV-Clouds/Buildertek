public class QBInvoiceJSON {

    // public class MetaData{
    //     public String CreateTime;
    //     public String LastModifiedByRef;
    //     public String LastUpdatedTime;
    // }

    // public class CustomField{
    //     public String DefinitionId;
    //     public String Name;
    //     public String Type;
    //     public String StringValue;
    // }

    // public class LinkedTxn{
    //     public String TxnId;
    //     public String TxnType;
    // }

    // public class CurrencyRef {
	// 	public String value;
	// 	public String name;
	// }

    // public class ItemAccountRef{
    //     public String value;
	// 	public String name;
    // }

    // public class ItemRef{
    //     public String value;
	// 	public String name;
    // }

    // public class SalesTermRef{
    //     public String value;
	// 	public String name;
    // }

    // public class SalesItemLineDetail{
    //     public ItemRef ItemRef;
    //     public Double UnitPrice;
    //     public Double Qty;
    //     public ItemAccountRef ItemAccountRef;
    //     public String TaxCodeRef;
    // }

    // public class BillAddr{
    //     public String Id;
    //     public String Line1;
    //     public String Line2;
    //     public String Line3;
    //     public String Line4;
    //     public String Lat;
    //     public String Long_x;

    // }

    // public class BillEmail{
    //     public String Address;
    // }

    // public class TxnTaxDetail{
    //     public String TxnTaxCodeRef;
    //     public Double TotalTax;
    //     public TaxLine TaxLine;

    // }

    // public class TaxLineDetail{
    //     public String TaxRateRef;
    //     public String PercentBased;
    //     public Double TaxPercent;
    //     public Double NetAmountTaxable;
    // }

    // public class TaxLine{
    //     public String Amount;
    //     public String DetailType;
    //     public TaxLineDetail TaxLineDetail;
    // }

    // public class ShipAddr{
    //     public String Id;
    //     public String Line1;
    //     public String City;
    //     public String CountrySubDivisionCode;
    //     public String PostalCode;
    //     public String Lat;
    //     public String Long_x;
    // }

    // public class line{
    //     public String Id;
    //     public String LineNum;
    //     public String Description;
    //     public Double Amount;
    //     public LinkedTxn LinkedTxn;
    //     public String DetailType;
    //     public SalesItemLineDetail SalesItemLineDetail;
    //     public String SubTotalLineDetail;
    //     public Double Qty;

    // }
    // public class CustomerRef{
    //     public String name;
    //     public String value;

    // }

    //     public String Id;
    //     public String domain;
	// 	public Boolean sparse;
    //     public String SyncToken;
    //     public MetaData MetaData;
    //     public CustomField CustomField;
    //     public String DocNumber;
    //     public String TxnDate;
    //     public CurrencyRef CurrencyRef;
    //     public LinkedTxn LinkedTxn;
    //     public List<line> Line;
    //     public TxnTaxDetail TxnTaxDetail;
    //     public CustomerRef CustomerRef;
    //     public String CustomerMemo;
    //     public BillAddr BillAddr;
    //     public ShipAddr ShipAddr;
    //     public Boolean FreeFormAddress;
    //     public SalesTermRef SalesTermRef;
    //     public Date DueDate;
    //     public String TotalAmt;
    //     public Boolean ApplyTaxAfterDiscount;
    //     public String PrintStatus;
    //     public String EmailStatus;
    //     public BillEmail BillEmail;
    //     public Double Balance;
    //     public Boolean AllowIPNPayment;
    //     public Boolean AllowOnlinePayment;
    //     public Boolean AllowOnlineCreditCardPayment;
    //     public Boolean AllowOnlineACHPayment;

    // public Invoice Invoice;
		// public String time;
	public class TxnTaxDetail{
		public Double TotalTax;
		public TxnTaxCodeRef TxnTaxCodeRef;
		public list<TaxLine> TaxLine;
	}
	public class TxnTaxCodeRef{
		public String value;
	}
	public class TaxRateRef{
		public String value;
	}
	public class TaxLineDetail{
		public TaxRateRef TaxRateRef;
		public Boolean PercentBased;
		public Double TaxPercent;
		public Double NetAmountTaxable;
	}
	public class TaxLine{
		public TaxLineDetail TaxLineDetail;
		public String DetailType;
		public Double Amount;
	}
	public class TaxCodeRef{
		public String value;
	}
	public class ShipAddr{
		public String City;
		public String Line1;
		public String PostalCode;
		// public String Long;
		public String CountrySubDivisionCode;
		public String Lat;
		public String Id;
	}
	public class SalesTermRef{
		public String value;
	}
	public class SalesItemLineDetail{
		public ItemRef ItemRef;
		public Double Qty;
		public Double UnitPrice;
		public TaxCodeRef TaxCodeRef;
	}
	public class ProjectRef{
		public String value;
	}
	public class MetaData{
		public String CreateTime;
		public String LastUpdatedTime;
	}
	public class LinkedTxn{
		public String TxnType;
		public String TxnId;
	}
	public class Line{
		public String Id;
		public SalesItemLineDetail SalesItemLineDetail;
		public Double LineNum;
		public Double Amount;
		public String DetailType;
		public String Description;
	}
	public class ItemRef{
		public String value;
		public String name;
	}
		public TxnTaxDetail TxnTaxDetail;
		public list<LinkedTxn> LinkedTxn;
		public Double Balance;
		public CustomerRef CustomerRef;
		public Double Deposit;
		public String SyncToken;
		public ProjectRef ProjectRef;
		public BillEmail BillEmail;
		public CustomerMemo CustomerMemo;
		public ShipAddr ShipAddr;
		public Boolean sparse;
		public String EmailStatus;
		public String DocNumber;
		public BillAddr BillAddr;
		public Boolean ApplyTaxAfterDiscount;
		public MetaData MetaData;
		public String DueDate;
		public Double TotalAmt;
		public SalesTermRef SalesTermRef;
		public list<Line> Line;
		public String PrintStatus;
		public list<CustomField> CustomField;
		public String domain;
		public String Id;
		public Date TxnDate;
        
	public class CustomField{
		public String DefinitionId;
		public String Type;
		public String Name;
		public String StringValue;
	}
	public class CustomerRef{
		public String name;
		public String value;
	}
	public class CustomerMemo{
		public String value;
	}
	public class BillEmail{
		public String Address;
	}
	public class BillAddr{
		public String Line1;
		// public String Long;
		public String Line2;
		public String Lat;
		public String Line3;
		public String Id;
		public String Line4;
	}
    

        public static QBInvoiceJSON parse(String json) {
            return (QBInvoiceJSON) System.JSON.deserialize(json, QBInvoiceJSON.class);
        }

    //     public static QBInvoiceJSON.Invoice parseCustomer(String json) {
    //         return (QBInvoiceJSON.Invoice) System.JSON.deserialize(json, QBInvoiceJSON.Invoice.class);
    // }
}