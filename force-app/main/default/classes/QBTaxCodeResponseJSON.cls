public class QBTaxCodeResponseJSON {
    public List<TaxRateDetails> TaxRateDetails;
	public String TaxCode;	
	public String TaxCodeId;

	public class TaxRateDetails {
		public String TaxRateName;	
		public String TaxRateId;
		public Double RateValue;	
		public String TaxAgencyId;
		public String TaxApplicableOn;	
	}
	public static QBTaxCodeResponseJSON parse(String json){
		return (QBTaxCodeResponseJSON) System.JSON.deserialize(json, QBTaxCodeResponseJSON.class);
	}
}