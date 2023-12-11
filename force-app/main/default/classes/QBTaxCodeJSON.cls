public class QBTaxCodeJSON {

    public List<TaxRateDetails> TaxRateDetails;
	public String TaxCode;	//sd

	public class TaxRateDetails {
		public String RateValue;	//8
		public String TaxApplicableOn;	//Sales
		public String TaxAgencyId;	//1
		public String TaxRateName;	//sf
	}
	public static QBTaxCodeJSON parse(String json){
		return (QBTaxCodeJSON) System.JSON.deserialize(json, QBTaxCodeJSON.class);
	}
}