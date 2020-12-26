import QtQuick 2.11
import QtQuick.Controls 2.11
import QtQuick.Layouts 1.4
import QtBluetooth 5.14
import Qt.labs.settings 1.0

import org.qfield 1.0

import Theme 1.0

Page {
  signal finished

  property alias showScaleBar: registry.showScaleBar
  property alias fullScreenIdentifyView: registry.fullScreenIdentifyView
  property alias locatorKeepScale: registry.locatorKeepScale
  property alias incrementalRendering: registry.incrementalRendering
  property alias numericalDigitizingInformation: registry.numericalDigitizingInformation
  property alias nativeCamera: registry.nativeCamera
  property alias autoSave: registry.autoSave
  property alias mouseAsTouchScreen: registry.mouseAsTouchScreen
  property alias verticalGrid: registry.verticalGrid
  property alias positioningDevice: registry.positioningDevice
  property alias positioningDeviceName: registry.positioningDeviceName

  Settings {
    id: registry
    property bool showScaleBar
    property bool fullScreenIdentifyView
    property bool locatorKeepScale
    property bool incrementalRendering
    property bool numericalDigitizingInformation
    property bool nativeCamera: true
    property bool autoSave
    property bool mouseAsTouchScreen
    property string verticalGrid: ""
    property string positioningDevice: "internal"
    property string positioningDeviceName: qsTr( "Internal device" );
  }

  ListModel {
      id: settingsModel
      ListElement {
          title: qsTr( "Show scale bar" )
          settingAlias: "showScaleBar"
      }
      ListElement {
          title: qsTr( "Maximized attribute form" )
          settingAlias: "fullScreenIdentifyView"
      }
      ListElement {
          title: qsTr( "Fixed scale navigation" )
          description: qsTr( "When fixed scale navigation is active, focusing on a search result will pan to the feature. With fixed scale navigation disabled it will pan and zoom to the feature." )
          settingAlias: "locatorKeepScale"
      }
      ListElement {
          title: qsTr( "Progressive rendering" )
          description: qsTr( "When progressive rendering is enabled, the map will be drawn every 250 milliseconds while rendering." )
          settingAlias: "incrementalRendering"
      }
      ListElement {
          title: qsTr( "Show digitizing information" )
          description: qsTr( "When switched on, coordinate information, such as latitude and longitude, is overlayed onto the map while digitizing new features or using the measure tool." )
          settingAlias: "numericalDigitizingInformation"
      }
      ListElement {
          title: qsTr( "Use native camera" )
          description: qsTr( "If disabled, QField will use a minimalist internal camera instead of the camera app on the device.<br>Tip: Enable this option and install the open camera app to create geo tagged photos." )
          settingAlias: "nativeCamera"
      }
      ListElement {
          title: qsTr( "Fast editing mode" )
          description: qsTr( "If enabled, the feature is stored after having a valid geometry and the constraints are fulfilled and atributes are commited immediately." )
          settingAlias: "autoSave"
      }
      ListElement {
          title: qsTr( "Consider mouse as a touchscreen device" )
          description: qsTr( "If disabled, the mouse will act as a stylus pen." )
          settingAlias: "mouseAsTouchScreen"
      }
  }

  Rectangle {
    color: "white"
    anchors.fill: parent
  }

  ColumnLayout {
    anchors {
      top: parent.top
      left: parent.left
      right: parent.right
      bottom: parent.bottom
    }

    TabBar {
      id: bar
      currentIndex: swipeView.currentIndex
      Layout.fillWidth: true
      Layout.preferredHeight: 48

      TabButton {
        text: qsTr("General")
        font: Theme.defaultFont
        anchors.verticalCenter : parent.verticalCenter
      }
      TabButton {
        text: qsTr("Variables")
        font: Theme.defaultFont
        anchors.verticalCenter : parent.verticalCenter
      }
      TabButton {
        text: qsTr("Grids")
        font: Theme.defaultFont
        anchors.verticalCenter : parent.verticalCenter
      }
      TabButton {
        height: 48
        text: qsTr("Positioning")
        font: Theme.defaultFont
        anchors.verticalCenter : parent.verticalCenter
      }
    }

    SwipeView {
      id: swipeView
      width: mainWindow.width
      currentIndex: bar.currentIndex
      Layout.fillHeight: true
      Layout.fillWidth: true

      ListView {
        flickableDirection: Flickable.VerticalFlick
        boundsBehavior: Flickable.StopAtBounds
        width: mainWindow.width
        clip: true
        ScrollBar.vertical: ScrollBar {}

        model: settingsModel

        delegate: Row {
          width: parent.width - 16

          Column {
            width: parent.width - toggle.width
            Label {
              width: parent.width
              padding: 8
              leftPadding: 22
              text: title
              font: Theme.defaultFont
              wrapMode: Text.WordWrap
              MouseArea {
                  anchors.fill: parent
                  onClicked: toggle.toggle()
              }
            }

            Label {
              width: parent.width
              visible: !!description
              padding: !!description ? 8 : 0
              topPadding: 0
              leftPadding: 22
              text: description || ''
              font: Theme.tipFont
              color: Theme.gray
              wrapMode: Text.WordWrap
            }
          }

          QfSwitch {
            id: toggle
            width: implicitContentWidth
            checked: registry[settingAlias]
            Layout.alignment: Qt.AlignTop | Qt.AlignRight
            onCheckedChanged: registry[settingAlias] = checked
          }
        }
      }

      Item {
        VariableEditor {
          id: variableEditor
          anchors.fill: parent
          anchors.margins: 4
        }
      }

      Item {
          ColumnLayout {
              anchors.fill: parent
              anchors.topMargin: 8
              anchors.leftMargin: 18
              anchors.rightMargin: 18

              Label {
                  text: qsTr( "Select a vertical grid shift in the combo box below to increase vertical location accuracy. Leave blank to disable this feature." )
                  font: Theme.defaultFont

                  wrapMode: Text.WordWrap
                  Layout.fillWidth: true
              }

              ComboBox {
                  Layout.fillWidth: true
                  model: [ qsTr( "No grid (use raw altitude from device)" ) ].concat( platformUtilities.availableGrids() );

                  onCurrentIndexChanged: {
                      if ( currentIndex > 0 ) {
                          verticalGrid = platformUtilities.availableGrids()[currentIndex - 1];
                      } else {
                          verticalGrid = '';
                      }
                  }

                  Component.onCompleted: {
                      currentIndex = verticalGrid !== '' ? find(verticalGrid) : 0;
                  }
              }

              Item {
                  // spacer item
                  Layout.fillWidth: true
                  Layout.fillHeight: true
              }
          }
      }

      Item {
          ColumnLayout {
              anchors.fill: parent
              anchors.topMargin: 8
              anchors.leftMargin: 18
              anchors.rightMargin: 18

              Label {
                  text: qsTr( "Select the positioning device" )
                  font: Theme.defaultFont

                  wrapMode: Text.WordWrap
                  Layout.fillWidth: true
              }

              RowLayout {
                  ComboBox {
                      id: bluetoothDeviceCombo
                      enabled: bluetoothDeviceModel.scanningStatus !== BluetoothDeviceModel.Scanning
                      Layout.fillWidth: true
                      Layout.alignment: Qt.AlignVCenter
                      textRole: 'display'
                      model: BluetoothDeviceModel {
                          id: bluetoothDeviceModel
                      }

                      property string selectedPositioningDevice

                      onCurrentIndexChanged: {
                          if( bluetoothDeviceModel.scanningStatus !== BluetoothDeviceModel.Scanning )
                          {
                            selectedPositioningDevice = bluetoothDeviceModel.data(bluetoothDeviceModel.index(currentIndex, 0), BluetoothDeviceModel.DeviceAddressRole );
                          }
                          if( positioningDevice !== selectedPositioningDevice )
                          {
                            positioningDevice = selectedPositioningDevice
                            positioningDeviceName = bluetoothDeviceModel.data(bluetoothDeviceModel.index(currentIndex, 0), BluetoothDeviceModel.DeviceNameRole );
                            positionSource.device = positioningDevice
                          }
                      }

                      Component.onCompleted: {
                          currentIndex = find(positioningDeviceName + ' (' + positioningDevice + ')');
                      }

                      Connections {
                        target: bluetoothDeviceModel

                        function onModelReset() {
                            bluetoothDeviceCombo.currentIndex = bluetoothDeviceModel.findAddressIndex(positioningDevice)
                        }

                        function onScanningStatusChanged(scanningStatus) {
                            if( scanningStatus === BluetoothDeviceModel.Scanning )
                                displayToast( qsTr('Scanning for paired devices') )
                            if( scanningStatus === BluetoothDeviceModel.Failed )
                                displayToast( qsTr('Scanning failed: %1').arg( bluetoothDeviceModel.lastError ) )
                            if( scanningStatus === BluetoothDeviceModel.Succeeded )
                                displayToast( qsTr('Scanning succeeded: %1 devices found').arg( bluetoothDeviceModel.rowCount() ) )
                            if( scanningStatus === BluetoothDeviceModel.Canceled )
                                displayToast( qsTr('Scanning canceled.') )
                        }
                      }
                  }

                  Rectangle {
                      color: "transparent"
                      Layout.preferredWidth: childrenRect.width
                      Layout.preferredHeight: childrenRect.height
                      Layout.alignment: Qt.AlignVCenter

                      QfButton {
                        id: scanButton
                        leftPadding: 10
                        rightPadding: 10
                        font: Theme.defaultFont
                        text: qsTr('Scan')

                        onClicked: {
                            bluetoothDeviceModel.startServiceDiscovery( false )
                        }
                        onPressAndHold: {
                          fullDiscoveryDialog.open()
                        }

                        enabled: bluetoothDeviceModel.scanningStatus !== BluetoothDeviceModel.Scanning
                        opacity: enabled ? 1 : 0
                      }


                      BusyIndicator {
                        id: busyIndicator
                        anchors.centerIn: scanButton
                        width: 36
                        height: 36
                        running: bluetoothDeviceModel.scanningStatus === BluetoothDeviceModel.Scanning
                      }
                  }

                  Dialog {
                    id: fullDiscoveryDialog
                    parent: mainWindow.contentItem

                    visible: false
                    modal: true

                    x: ( mainWindow.width - width ) / 2
                    y: ( mainWindow.height - height ) / 2

                    title: qsTr( "Make a full service discovery" )
                    Label {
                      width: parent.width
                      wrapMode: Text.WordWrap
                      text: qsTr( 'A full device scan can take longer. You really want to do it?\nCancel to make a minimal device scan instead.')
                    }

                    standardButtons: Dialog.Ok | Dialog.Cancel
                    onAccepted: {
                        bluetoothDeviceModel.startServiceDiscovery( true )
                        visible = false
                    }
                    onRejected: {
                        bluetoothDeviceModel.startServiceDiscovery( false )
                        visible = false
                    }
                  }
              }

              Label {
                  text: qsTr( "Status: %1" ).arg( positionSource.bluetoothSocketState )
                  font: Theme.defaultFont

                  wrapMode: Text.WordWrap
                  Layout.fillWidth: true
              }

              QfButton {
                id: connectButton
                Layout.fillWidth: true
                Layout.topMargin: 5
                font: Theme.defaultFont
                text: positionSource.bluetoothSocketState !== BluetoothSocket.UnconnectedState ? qsTr('Connecting to %1').arg(positioningDeviceName) : qsTr('Connect  to %1').arg(positioningDeviceName)
                enabled: positionSource.bluetoothSocketState === BluetoothSocket.UnconnectedState
                visible: positioningDevice !== 'internal' && positionSource.bluetoothSocketState !== BluetoothSocket.ConnectedState

                onClicked: {
                    positionSource.connectBluetoothSource()
                }
              }

              Item {
                  // spacer item
                  Layout.fillWidth: true
                  Layout.fillHeight: true
              }
          }
      }
    }
  }

  header: PageHeader {
      title: qsTr("QField Settings")

      showApplyButton: true
      showCancelButton: false

      onFinished: {
          parent.finished()
          variableEditor.apply()
      }
    }

  Keys.onReleased: {
    if (event.key === Qt.Key_Back || event.key === Qt.Key_Escape) {
      event.accepted = true
      variableEditor.apply()
    }
  }
}
