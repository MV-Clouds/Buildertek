public without sharing class QBReceiptResponseJSON {
    // public Payment Payment;

	// public class ProjectRef{
	// 	public String value;
	// }
	// public class Payment{
	// 	public Boolean sparse;
	// 	public list<String> Line;
	// 	public Boolean ProcessPayment;
	// 	public ProjectRef ProjectRef;
	// 	public CustomerRef CustomerRef;
	// 	public Double TotalAmt;
	// 	public String Id;
	// 	// public Date TxnDate;
	// 	public DepositToAccountRef DepositToAccountRef;
	// 	public Double UnappliedAmt;
	// 	public String domain;
	// 	public MetaData MetaData;
	// 	public String SyncToken;
	// }
	// public class MetaData{
	// 	public String CreateTime;
	// 	public String LastUpdatedTime;
	// }
	// public class DepositToAccountRef{
	// 	public String value;
	// }
	// public class CustomerRef{
	// 	public String name;
	// 	public String value;
	// }

	public Payment Payment;
		// public String time;
	public class ProjectRef{
		public String value;
	}
	public class PaymentMethodRef{
		public String value;
	}
	public class Payment{
		public ProjectRef ProjectRef;
		public Boolean sparse;
		public String PaymentRefNum;
		public list<Line> Line;
		public Double TotalAmt;
		public CustomerRef CustomerRef;
		public String TxnDate;
		public String Id;
		public Double UnappliedAmt;
		public PaymentMethodRef PaymentMethodRef;
		public String domain;
		public MetaData MetaData;
		public String SyncToken;
	}
	public class MetaData{
		public String CreateTime;
		public String LastUpdatedTime;
	}
	public class LinkedTxn{
		public String TxnId;
		public String TxnType;
	}
	public class Line{
		public list<LinkedTxn> LinkedTxn;
		public Double Amount;
	}
	public class CustomerRef{
		public String value;
	}

    public static QBReceiptResponseJSON parse(String json_Body) {
		return (QBReceiptResponseJSON) JSON.deserialize(json_Body, QBReceiptResponseJSON.class);
	}
}