/*
 * MultiselectController synchronizes the values of the hidden elements to the
 * SelectOption lists.
 */
public with sharing class MultiselectController {

    public MultiselectController(){
        System.debug('leftOptions ==>' + leftOptions);
        System.debug('rightOptions ==>' + rightOptions);
        // TRS_FilterCandidates.testMHR();
    }
    // SelectOption lists for public consumption
    public SelectOption[] leftOptions { get; set; }
    public SelectOption[] rightOptions { get; set; }
    
    // Parse &-separated values and labels from value and 
    // put them in option
    private void setOptions(SelectOption[] options, String value) {
        try {
            System.debug('Option ==>' +options);
            // options.clear();
            System.debug('value ==>' +value);
            String[] parts = value.split('&');
            System.debug('parts ==>' +parts);
            System.debug('parts.size() ==>' +parts.size());
            
            for (Integer i=0; i<parts.size()/2; i++) {
                options.add(new SelectOption(EncodingUtil.urlDecode(parts[i*2], 'UTF-8'), 
                  EncodingUtil.urlDecode(parts[(i*2)+1], 'UTF-8')));
            }
        } catch (Exception ex) {
            System.debug('ex=>'+ex);
            System.debug(ex.getLineNumber());
            System.debug(ex.getMessage());
        }
    }

    private void rightSetOptions(SelectOption[] options, String value) {
        try {
            System.debug('Option ==>' +options);
            System.debug('value ==>' +value);
            // options.clear();
            // System.debug('Option After==>' +options);
            String[] parts = value.split('&');
            System.debug('parts ==>' +parts);
            System.debug('parts.size() ==>' +parts.size());
            
            System.debug('right side ==>');

            // SelectOption[] optionsTemp;
            List<SelectOption> optionsTemp = new List<SelectOption>();

            for (Integer i=0; i<parts.size()/2; i++) {
                optionsTemp.add(new SelectOption(EncodingUtil.urlDecode(parts[i*2], 'UTF-8'), 
                  EncodingUtil.urlDecode(parts[(i*2)+1], 'UTF-8')));
            }
            System.debug('optionsTemp ==>' + optionsTemp);
            options = optionsTemp;
            System.debug('options ==>' + options);
            
            rightOptions = options;
            System.debug('rightOptions ==>' + options);

            List<String> all = new List<String>();
            TRS_FilterCandidates.testMHR(optionsTemp);


        } catch (Exception ex) {
            System.debug('ex=>'+ex);
            System.debug(ex.getLineNumber());
            System.debug(ex.getMessage());
        }
    }
    
    // Backing for hidden text field containing the options from the
    // left list
    public String leftOptionsHidden { get; set {
           leftOptionsHidden = value;
           setOptions(leftOptions, value);
        }
    }
    
    // Backing for hidden text field containing the options from the
    // right list
    public String rightOptionsHidden { get; set {
           rightOptionsHidden = value;
           rightSetOptions(rightOptions, value);
        }
    }
}