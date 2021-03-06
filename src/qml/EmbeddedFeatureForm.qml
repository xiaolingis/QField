import QtQuick 2.12
import QtQuick.Controls 2.12

import org.qfield 1.0

Popup {
    id: formPopup

    property alias state: form.state

    property alias currentLayer: formFeatureModel.currentLayer
    property alias linkedRelation: formFeatureModel.linkedRelation
    property alias linkedParentFeature: formFeatureModel.linkedParentFeature
    property alias feature: formFeatureModel.feature
    property alias attributeFormModel: formAttributeFormModel

    onAboutToShow: {
        if( state === 'Add' ) {
           form.featureCreated = false
           formFeatureModel.resetAttributes()
        }
    }

    signal featureSaved
    signal featureCancelled

    parent: ApplicationWindow.overlay

    x: 24
    y: 24
    padding: 0
    width: parent.width - 48
    height: parent.height - 48
    modal: true
    closePolicy: Popup.CloseOnEscape

    FeatureForm {
        id: form
        property bool isSaved: false

        model: AttributeFormModel {
            id: formAttributeFormModel
            featureModel: FeatureModel {
                id: formFeatureModel
            }
        }

        focus: true

        embedded: true
        toolbarVisible: true

        anchors.fill: parent

        onConfirmed: {
            formPopup.featureSaved()
            closePopup()
        }

        onCancelled: {
            formPopup.featureCancelled()
            closePopup()
        }

        function closePopup(){
            if( formPopup.opened ){
                isSaved = true
                formPopup.close()
            }else{
                isSaved = false
            }
        }
    }

    onClosed: {
      if( !form.isSaved ){
          form.confirm()
      }else{
          form.isSaved = false
      }
    }
}
