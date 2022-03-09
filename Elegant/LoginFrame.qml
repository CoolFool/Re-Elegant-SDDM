import QtQuick 2.0
import QtGraphicalEffects 1.0
import SddmComponents 2.0

Item {
    id: frame
    property int sessionIndex: sessionModel.lastIndex
    property string userName: userModel.lastUser
    property bool isProcessing: glowAnimation.running
    property alias input: passwdInput
    property alias button: loginButton

    Connections {
        target: sddm
        onLoginSucceeded: {
            glowAnimation.running = false
            Qt.quit()
        }
        onLoginFailed: {
            glowAnimation.running = false
            wrongPasswdAnimation.running = true
            passwdInput.focus = true            
        }
    }
     
    Item {
        id: loginItem
        anchors.centerIn: parent
        width: parent.width
        height: parent.height

        UserAvatar {
            id: userIconRec
            anchors {
                top: parent.top
                topMargin: parent.height / 4
                horizontalCenter: parent.horizontalCenter
            }
            width: 130
            height: 130
            source: userFrame.currentIconPath
            onClicked: {
                root.state = "stateUser"
                userFrame.focus = true
            }
        }

        Glow {
            id: avatarGlow
            anchors.fill: userIconRec
            radius: 0
            samples: 17
            color: "#99ffffff"
            source: userIconRec

            SequentialAnimation on radius {
                id: glowAnimation
                running: false
                alwaysRunToEnd: true
                loops: Animation.Infinite
                PropertyAnimation { to: 20 ; duration: 500}
                PropertyAnimation { to: 0 ; duration: 500}
            }
        }
        
        Text {
            id: userNameText
            visible: false
            anchors {
                top: userIconRec.bottom
                topMargin: 10
            }
            anchors.horizontalCenter: parent.horizontalCenter

            text: userName
            color: textColor
            font.pointSize: 1
        }

        Rectangle {
            id: passwdInputRec
            visible: ! isProcessing
            anchors {
                top: userNameText.bottom
                topMargin: 7
            }
           
            width: 260
            height: 35
            radius: 3
            color: "#55000000"
            x: parent.width / 2 - width/2
            TextInput {
                id: passwdInput
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8 + 36
                clip: true
                focus: true
                color: textColor
                font.pointSize: 5
                selectByMouse: true
                selectionColor: "#55ababab"
                echoMode: TextInput.Password
                verticalAlignment: TextInput.AlignVCenter
                
                onFocusChanged: {
                    if (focus) {
                        color = textColor
                        echoMode = TextInput.Password
                        text = ""
                    }
                }
                onAccepted: {
                    glowAnimation.running = true
                    sddm.login(userNameText.text, passwdInput.text, sessionIndex)
                }
               

                KeyNavigation.backtab: {
                    if (sessionButton.visible) {
                        return sessionButton
                    }
                    else if (userButton.visible) {
                        return userButton
                    }
                    else {
                        return shutdownButton
                    }
                }
                KeyNavigation.tab: loginButton
                Timer {
                    interval: 200
                    running: true
                    onTriggered: passwdInput.forceActiveFocus()
                }
            }
            ImgButton {
                id: loginButton
                height: passwdInput.height
                width: height
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }

                normalImg: "icons/login_normal.png"
                hoverImg: "icons/login_normal.png"
                pressImg: "icons/login_press.png"
                onClicked: {
                    glowAnimation.running = true
                    sddm.login(userNameText.text, passwdInput.text, sessionIndex)
                }
                KeyNavigation.tab: shutdownButton
                KeyNavigation.backtab: passwdInput
            }
        }

        SequentialAnimation {
            id: wrongPasswdAnimation
            running: false
            loops: 1
            alwaysRunToEnd: true
            PropertyAction { target: passwdInput; property: "echoMode"; value: TextInput.Normal }
            PropertyAction { target: passwdInput; property: "text"; value: textConstants.loginFailed }
            PropertyAction { target: passwdInput; property: "focus"; value: false }
            PropertyAction { target: passwdInput; property: "color"; value: "#dd3d38" }
            PropertyAction { target: passwdInputRec; property: "border.color"; value: "#50dd3d38" }
            PathAnimation {
                target: passwdInputRec
                duration: 600
                path: Path {
                        PathLine {x:parent.width / 2 - passwdInputRec.width/2 + 4}
                        PathLine {x:parent.width / 2 - passwdInputRec.width/2 - 8}
                        PathLine {x:parent.width / 2 - passwdInputRec.width/2 + 12}
                        PathLine {x:parent.width / 2 - passwdInputRec.width/2 - 16}
                        PathLine {x:parent.width / 2 - passwdInputRec.width/2 + 20}
                        PathLine {x:parent.width / 2 - passwdInputRec.width/2 - 24}
                        PathLine {x:parent.width / 2 - passwdInputRec.width/2}
                    }
                }
            PropertyAction { target: passwdInputRec; property: "border.color"; value: "#55000000" }
            }
        }
    }
