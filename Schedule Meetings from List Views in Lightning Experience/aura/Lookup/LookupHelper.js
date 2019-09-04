/**
 * @author Jai Chaturvedi
 * @author Emiliano Torrano
 */
({
  //Function to toggle the record list drop-down
  toggleLookupList: function (component, id, inputClass) {
    $A.util.toggleClass(component.find(id), inputClass || 'slds-is-open');
  },

  //function to call SOSL apex method.
  searchSOSLHelper: function (component, searchText) {
    //validate the input length. Must be greater then 3.
    //This check also manages the SOSL exception. Search text must be greater then 2.
    if (searchText && searchText.length > 1) {
      //show the loading icon for search input field
      var action = component.get('c.search');
      var objectAPIName = component.get('v.objectAPIName');
      action.setParams({
        objectAPIName: objectAPIName,
        searchText: searchText,
        whereClause: component.get('v.filter'),
        extrafields: component.get('v.subHeadingFieldsAPI')
      });

      action.setCallback(this, function (a) {
        var state = a.getState();
        if (component.isValid() && state === 'SUCCESS') {
          
          //parsing JSON return to Object[]
          var result = [].concat.apply([], JSON.parse(a.getReturnValue()));
          component.set('v.matchingRecords', result);
          //Visible the list if record list has values
          $A.util.addClass(component.find('lookupdiv'), 'slds-is-open');
        }
      });
      $A.enqueueAction(action);
    } else {
      //hide the drop down list if input length less then 3
      this.toggleLookupList(component, 'slds-combobox-lookup', 'slds-is-open');
    }
  },

  //function to call SOQL apex method.
  searchSOQLHelper: function (component) {
    var action = component.get('c.getRecentlyViewed');
    action.setParams({
      objectAPIName: component.get('v.objectAPIName'),
      whereClause: component.get('v.filter'),
      extrafields: component.get('v.subHeadingFieldsAPI')
    });
    // Configure response handler
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (component.isValid() && state === 'SUCCESS') {
        
        if (response.getReturnValue()) {
          component.set('v.matchingRecords', response.getReturnValue());
          if (response.getReturnValue().length > 0) {
            $A.util.addClass(component.find('lookupdiv'), 'slds-is-open');
          }
        }
      }
    });
    $A.enqueueAction(action);
  },
  handleUpdateObjectAPIName: function (component, objectApiName) {
    var objectApiName = objectApiName || 'Contact';
    var combo_options = component.get('v.combo_options_map');
    var validKey = objectApiName in combo_options;
    var label = (validKey && combo_options[objectApiName].label) || '';
    var iconType = (validKey && combo_options[objectApiName].icon) || '';
    var iconClass = (validKey && combo_options[objectApiName].class) || '';
    var subHeadingFieldsAPI = (validKey && combo_options[objectApiName].fieldLabels) || [];
    component.set('v.iconType', iconType);
    component.set('v.iconClass', iconClass);
    component.set('v.subHeadingFieldsAPI', subHeadingFieldsAPI);
    component.set('v.placeholder', 'Search ' + label + '...');
  },
  clearInputError: function (component, inputId) {
    var input = component.find(inputId);
    input.setCustomValidity('');
    input.reportValidity();
  },
  filterObjectRestrictions: function (component, map, callback) {

    var action = component.get('c.filterObjectRestrictions');
    action.setParams({
      maps: map
    });

    action.setCallback(this, callback)
    
    $A.enqueueAction(action);
  }


});