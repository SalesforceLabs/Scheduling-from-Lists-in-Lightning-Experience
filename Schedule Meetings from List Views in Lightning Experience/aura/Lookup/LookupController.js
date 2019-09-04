/**
 * @author Jai Chaturvedi
 * @author Emiliano Torrano
 */
({
  doInit: function(component, event, helper) {
    var objectSelector = component.find('objectSelector');
    var inputSearch = component.find('input-search');
    
    if (objectSelector) {
        
        var combo_options_map = component.get('v.combo_options_map');
        helper.filterObjectRestrictions(component,combo_options_map, function(response) {
          
          if (response.getState() == 'SUCCESS') {
            combo_options_map = response.getReturnValue();
            component.get('v.disabled') &&
            $A.util.addClass(component.find('btn-combobox'), 'disabled');
            component.set('v.combo_options', Object.values(combo_options_map));
            var combo_options = [];
            Object.keys(combo_options_map).forEach(function(apiName) {
                var newElement = combo_options_map[apiName];
                newElement['Id'] = apiName;
                newElement['Name'] = newElement['label'];
                combo_options.push(newElement);
            });
            helper.handleUpdateObjectAPIName(component, Object.keys(combo_options_map)[0]);
            $A.util.addClass(inputSearch, 'input-label-hidden');
          }
        });
    }
  },
  handleObjectAPINameChange: function(component, event, helper) {
    // This will contain the string of the "value" attribute of the selected option
    var objectApiName = event.getParam('value') || 'Contact';
    objectApiName && helper.handleUpdateObjectAPIName(component, objectApiName);
  },
  handleComboboxClick: function(component, event, helper) {
    helper.toggleLookupList(component, 'combo-dropdown', 'slds-is-open');
  },

  handleComboboxOnBlur: function(component, event, helper) {
    $A.util.removeClass(component.find('combo-dropdown'), 'slds-is-open');
  },

  //Function to handle the LookupChooseEvent. Sets the chosen record Id and Name
  handleLookupChooseEvent: function(component, event, helper) {
    var comboId = 'lookupdiv';
    if (event.getSource().getLocalId() === 'combo-item-id') {
        comboId = 'combo-dropdown';
        var objectApiName = event.getParam('recordId');
        component.set('v.objectAPIName', objectApiName);
        component.set('v.chosenRecordId', null);
        component.set('v.chosenRecordLabel', null);
        helper.handleUpdateObjectAPIName(component, objectApiName);
    } else {
        component.set('v.chosenRecordId', event.getParam('recordId'));
        component.set('v.chosenRecordLabel', event.getParam('recordLabel'));
    }
    helper.toggleLookupList(component, comboId, 'slds-is-open');
  },

  //Function for finding the records as for given search input
  searchRecords: function(component, event, helper) {
    // Search Records if the user focus or change search input value, clear chosenRecordId if the event is a change.
    helper.clearInputError(component, 'searchinput');
    event.getName() === 'change' && component.set('v.chosenRecordId', undefined);
    var searchText = component.find('searchinput').get('v.value');
    if (searchText) {
      helper.searchSOSLHelper(component, searchText.trim());
    } else {
      helper.searchSOQLHelper(component);
    }
  },
  hideList: function(component, event, helper) {
    $A.util.removeClass(component.find('lookupdiv'), 'slds-is-open');
  },
  validateInput: function(component) {
    var searchInput = component.find('searchinput');
    var recordLabel = component.get("v.chosenRecordLabel");
    var recordId = component.get("v.chosenRecordId");
    if(component.get("v.required") && recordLabel && recordLabel === '') {
      searchInput.setCustomValidity("Complete this field");
    } else if(recordLabel && recordLabel !== '' && !recordId) {
      searchInput.setCustomValidity("An invalid option has been chosen.");
    } else {
      searchInput.setCustomValidity("");
    }
    return searchInput.reportValidity();
  }
});