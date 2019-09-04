/**
 * @author Jai Chaturvedi
 * @author Emiliano Torrano
 */
({
    loadValues : function (component) {
        var record = component.get("v.record");
        var subheading = '';
        var subHeadingFieldsAPI = component.get("v.subHeadingFieldsAPI");
        var itemLabel = record.label;
        if (subHeadingFieldsAPI && subHeadingFieldsAPI.length > 0) {
            var label = subHeadingFieldsAPI[0];
            itemLabel = record[label] || itemLabel;
            for (var i = 1; i < subHeadingFieldsAPI.length; i++) {
                var fields = subHeadingFieldsAPI[i].split('.');
                var fieldName = fields[0], field2 = fields.length > 1 && fields[1];
                var fieldValue = fieldName in record && (field2 ? record[fieldName][field2] : record[fieldName]);
                if (fieldValue) {
                    subheading = subheading + fieldValue + ' • ';
                }
            }
            subheading = subheading.substring(0, subheading.lastIndexOf('•'));
        }
        component.set('v.label', itemLabel);
        component.set("v.subHeadingFieldValues", subheading);
    },

    choose : function (component) {
        var chooseEvent = component.getEvent("lookupChoose");
        chooseEvent.setParams({
            "recordId": component.get("v.record").Id,
            "recordLabel":component.get("v.label")
        });
        chooseEvent.fire();
    }
})