public class QBInvoiceJSON {

    public class MetaData{
        public String CreateTime;
        public String LastModifiedByRef;
        public String LastUpdatedTime;
    }

    public class CustomField{
        public String DefinitionId;
        public String Name;
        public String Type;
        public String StringValue;
    }

    public class LinkedTxn{
        public String TxnId;
        public String TxnType;
    }

    public class CurrencyRef {
		public String value;
		public String name;
	}

    public class ItemAccountRef{
        public String value;
		public String name;
    }

    public class ItemRef{
        public String value;
		public String name;
    }

    public class SalesTermRef{
        public String value;
		public String name;
    }

    public class SalesItemLineDetail{
        public ItemRef ItemRef;
        public Double UnitPrice;
        public Integer Qty;
        public ItemAccountRef ItemAccountRef;
        public String TaxCodeRef;
    }

    public class BillAddr{
        public String Id;
        public String Line1;
        public String Line2;
        public String Line3;
        public String Line4;
        public String Lat;
        public String Long_x;

    }

    public class BillEmail{
        public String Address;
    }

    public class TxnTaxDetail{
        public String TxnTaxCodeRef;
        public Double TotalTax;
        public TaxLine TaxLine;

    }

    public class TaxLineDetail{
        public String TaxRateRef;
        public String PercentBased;
        public Integer TaxPercent;
        public Double NetAmountTaxable;
    }

    public class TaxLine{
        public String Amount;
        public String DetailType;
        public TaxLineDetail TaxLineDetail;
    }

    public class ShipAddr{
        public String Id;
        public String Line1;
        public String City;
        public String CountrySubDivisionCode;
        public String PostalCode;
        public String Lat;
        public String Long_x;
    }

    public class line{
        public String Id;
        public String LineNum;
        public String Description;
        public Double Amount;
        public LinkedTxn LinkedTxn;
        public String DetailType;
        public SalesItemLineDetail SalesItemLineDetail;
        public String SubTotalLineDetail;
    }
    public class CustomerRef{
        public String name;
        public String value;

    }

    public class Invoice{
        public String Id;
        public String domain;
		public Boolean sparse;
        public String SyncToken;
        public MetaData MetaData;
        public CustomField CustomField;
        public String DocNumber;
        public String TxnDate;
        public CurrencyRef CurrencyRef;
        public LinkedTxn LinkedTxn;
        public Line Line;
        public TxnTaxDetail TxnTaxDetail;
        public CustomerRef CustomerRef;
        public String CustomerMemo;
        public BillAddr BillAddr;
        public ShipAddr ShipAddr;
        public Boolean FreeFormAddress;
        public SalesTermRef SalesTermRef;
        public String DueDate;
        public String TotalAmt;
        public Boolean ApplyTaxAfterDiscount;
        public String PrintStatus;
        public String EmailStatus;
        public BillEmail BillEmail;
        public Double Balance;
        public Boolean AllowIPNPayment;
        public Boolean AllowOnlinePayment;
        public Boolean AllowOnlineCreditCardPayment;
        public Boolean AllowOnlineACHPayment;
    }

        public static QBInvoiceJSON parse(String json) {
            return (QBInvoiceJSON) System.JSON.deserialize(json, QBInvoiceJSON.class);
        }

        public static QBInvoiceJSON.Invoice parseCustomer(String json) {
            return (QBInvoiceJSON.Invoice) System.JSON.deserialize(json, QBInvoiceJSON.Invoice.class);
    }
}