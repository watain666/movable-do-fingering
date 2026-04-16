//=============================================================================
//  MuseScore Movable Do Fingering Plugin
//
//  Copyright (C) 2023 yezhiyi9670
//  based on the following code by Nozomu Yamazaki
//  https://github.com/nozomu-y/MovableDo
//  Modified for TiâuÛi - Support Unison Detection & Part Name Appending
//
//  License: http://www.gnu.org/licenses/gpl.html GPL version 2 or higher
//=============================================================================

import QtQuick 2.1
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import MuseScore 3.0
import Muse.UiComponents 1.0

MuseScore {
    version: "1.5"
    description: "Inserts movable do note names with smart unison suffix handling"
    menuPath: "Plugins.Movable Do Fingering"
    pluginType: "dialog"

    // <MuseScore 4.4 Metadata>
    title: "Movable Do Fingering"
    thumbnailName: "MovableDoFingering.png"
    categoryCode: "composing-arranging-tools"
    // </MuseScore 4.4 Metadata>

    function _quit() {
        (typeof(quit) === 'undefined' ? Qt.quit : quit)();
    }

    property real fontSizeMini: 0.7
    property real elementType: Element.FINGERING
    property real dialogControlWidth: 150

    function getUnisonPartNames(note, segment, currentTrack) {
        var unisonParts = [];
        var totalTracks = curScore.nstaves * 4;
        var currentStaffIdx = Math.floor(currentTrack / 4);

        for (var t = 0; t < totalTracks; t++) {
            var checkStaffIdx = Math.floor(t / 4);
            if (currentStaffIdx === checkStaffIdx) continue; 

            var el = segment.elementAt(t);
            if (el && el.type === Element.CHORD) {
                var elNotes = el.notes;
                for (var i = 0; i < elNotes.length; i++) {
                    if (elNotes[i].pitch === note.pitch) {
                        var pName = "Staff " + (checkStaffIdx + 1);
                        var targetPart = el.part || (curScore.parts && checkStaffIdx < curScore.parts.length ? curScore.parts[checkStaffIdx] : null);
                        
                        if (targetPart) {
                            if (targetPart.shortName && targetPart.shortName.trim() !== "") {
                                pName = targetPart.shortName;
                            } else if (targetPart.longName && targetPart.longName.trim() !== "") {
                                pName = targetPart.longName;
                            } else if (targetPart.partName && targetPart.partName.trim() !== "") {
                                pName = targetPart.partName;
                            }
                        }
                        
                        pName = pName.replace(/<\/?[^>]+(>|$)/g, "");

                        if (unisonParts.indexOf(pName) === -1) {
                            unisonParts.push(pName);
                        }
                        break;
                    }
                }
            }
        }
        return unisonParts;
    }

    function nameChord(notes, text, small, movableDoOffset, notationIndex, placementIndex, segment, displayModeIndex, unisonLabelPositionIndex, currentTrack, trackState) {
        var tpcToTonalPitch= {
            "31": "A##", "19": "B", "7":  "Cb", "24": "A#", "12": "Bb", "0":  "Cbb",
            "29": "G##", "17": "A", "5":  "Bbb", "22": "G#", "10": "Ab", "27": "F##",
            "15": "G", "3":  "Abb", "32": "E##", "20": "F#", "8":  "Gb", "25": "E#",
            "13": "F", "1":  "Gbb", "30": "D##", "18": "E", "6":  "Fb", "23": "D#",
            "11": "Eb", "-1": "Fbb", "28": "C##", "16": "D", "4":  "Ebb", "33": "B##",
            "21": "C#", "9": "Db", "26": "B#", "14": "C", "2":  "Dbb"
        }
        var tonalPitchToMovableDo = {
            'A##': ['t',  't', '7', 'Si'], 'A#':  ['li', '♯l', '♯6', '♯La'],
            'G##': ['l',  'l', '6', 'La'], 'G#':  ['si', '♯s', '♯5', '♯Sol'],
            'F##': ['s',  's', '5', 'Sol'], 'E##': ['fi', '♯f', '♯4', '♯Fa'],
            'E#':  ['f',  'f', '4', 'Fa'], 'D##': ['m',  'm', '3', 'Mi'],
            'D#':  ['ri', '♯r', '♯2', '♯Re'], 'C##': ['r',  'r', '2', 'Re'],
            'B##': ['di', '♯d', '♯1', '♯Do'], 'B#':  ['d',  'd', '1', 'Do'],
            'B':   ['t',  't', '7', 'Si'], 'Bb':  ['ta', '♭t', '♭7', '♭Si'],
            'A':   ['l',  'l', '6', 'La'], 'G':   ['s',  's', '5', 'Sol'],
            'F#':  ['fi', '♯f', '♯4', '♯Fa'], 'F':   ['f',  'f', '4', 'Fa'],
            'E':   ['m',  'm', '3', 'Mi'], 'Eb':  ['ma', '♭m', '♭3', '♭Mi'],
            'D':   ['r',  'r', '2', 'Re'], 'C#':  ['di', '♯d', '♯1', '♯Do'],
            'C':   ['d',  'd', '1', 'Do'], 'Cb':  ['t',  't', '7', 'Si'],
            'Cbb': ['ta', '♭t', '♭7', '♭Si'], 'Bbb': ['l',  'l', '6', 'La'],
            'Ab':  ['lo', '♭l', '♭6', '♭La'], 'Abb': ['s',  's', '5', 'Sol'],
            'Gb':  ['se', '♭s', '♭5', '♭Sol'], 'Gbb': ['f',  'f', '4', 'Fa'],
            'Fb':  ['m',  'm', '3', 'Mi'], 'Ebb': ['r',  'r', '2', 'Re'],
            'Fbb': ['ma', '♭m', '♭3', '♭Mi'], 'Db':  ['ro', '♭r', '♭2', '♭Re'],
            'Dbb': ['d',  'd', '1', 'Do'],
        }
        var sep = "\n"
        var oct = ""
        var name
        for (var i = 0; i < notes.length; i++) {
            if (!notes[i].visible) continue;
            
            var unisonParts = getUnisonPartNames(notes[i], segment, currentTrack);
            var isUnison = unisonParts.length > 0;
            var currentUnisonStr = unisonParts.join(", ");

            if (displayModeIndex === 1 && !isUnison) {
                trackState.lastUnison = "";
                continue;
            }

            if (text.text) text.text = sep + text.text
            if (small) text.fontSize *= fontSizeMini
            if (typeof notes[i].tpc === "undefined") return
            var tonalPitch = tpcToTonalPitch[String((parseInt(notes[i].tpc) - movableDoOffset + 35 + 1) % 35 - 1)]
            name = tonalPitchToMovableDo[tonalPitch][notationIndex]
            if (notes[i].tieBack !== null) {
                continue; 
            }

            var partLabel = "";
            if (isUnison) {
                if (currentUnisonStr !== trackState.lastUnison) {
                    partLabel = "(" + currentUnisonStr + ")";
                }
                trackState.lastUnison = currentUnisonStr;
            } else {
                trackState.lastUnison = "";
            }

            var renderedText = name + oct;
            if (partLabel !== "") {
                if (unisonLabelPositionIndex === 0) {
                    renderedText = partLabel + "\n" + renderedText;
                } else {
                    renderedText = renderedText + "\n" + partLabel;
                }
            }

            text.text = renderedText + text.text
        }
        text.placement = (placementIndex === 0) ? Placement.ABOVE : Placement.BELOW;
    }

    function renderGraceNoteNames(cursor, list, text, small, movableDoOffset, notationIndex, placementIndex, segment, displayModeIndex, unisonLabelPositionIndex, currentTrack, trackState) {
        if (list.length > 0) {
            for (var chordNum = 0; chordNum < list.length; chordNum++) {
                var chord = list[chordNum]
                nameChord(chord.notes, text, small, movableDoOffset, notationIndex, placementIndex, segment, displayModeIndex, unisonLabelPositionIndex, currentTrack, trackState)
                if (text.text) cursor.add(text)
                text.offsetX = chord.posX
                if (text.text) text = newElement(elementType)
            }
        }
        return text
    }

    function nameNotesMovableDo(tonalityText, notationIndex, placementIndex, displayModeIndex, unisonLabelPositionIndex) {
        var movableDoOffset = +tonalityText.split(' ')[0]
        var cursor = curScore.newCursor()
        var startStaff, endStaff, endTick
        var fullScore = false
        cursor.rewind(1)
        if (!cursor.segment) {
            fullScore = true
            startStaff = 0
            endStaff = curScore.nstaves - 1
        } else {
            startStaff = cursor.staffIdx
            cursor.rewind(2)
            endTick = (cursor.tick === 0) ? curScore.lastSegment.tick + 1 : cursor.tick
            endStaff = cursor.staffIdx
        }

        for (var staff = startStaff; staff <= endStaff; staff++) {
            for (var voice = 0; voice < 4; voice++) {
                cursor.rewind(1)
                cursor.voice = voice
                cursor.staffIdx = staff
                var currentTrack = staff * 4 + voice;
                
                var trackState = { lastUnison: "" };

                if (fullScore) cursor.rewind(0)
         
                while (cursor.segment && (fullScore || cursor.tick < endTick)) {
                    if (cursor.element && cursor.element.type === Element.CHORD) {
                        var text = newElement(elementType)
                        var leadingLifo = Array(), trailingFifo = Array()
                        var graceChords = cursor.element.graceNotes
                        if (graceChords.length > 0) {
                            for (var chordNum = 0; chordNum < graceChords.length; chordNum++) {
                                var noteType = graceChords[chordNum].notes[0].noteType
                                if (noteType === NoteType.GRACE8_AFTER || noteType === NoteType.GRACE16_AFTER || noteType === NoteType.GRACE32_AFTER) {
                                    trailingFifo.unshift(graceChords[chordNum])
                                } else {
                                    leadingLifo.push(graceChords[chordNum])
                                }
                            }
                        }

                        text = renderGraceNoteNames(cursor, leadingLifo, text, true, movableDoOffset, notationIndex, placementIndex, cursor.segment, displayModeIndex, unisonLabelPositionIndex, currentTrack, trackState)
                        nameChord(cursor.element.notes, text, false, movableDoOffset, notationIndex, placementIndex, cursor.segment, displayModeIndex, unisonLabelPositionIndex, currentTrack, trackState)
                        if (text.text) cursor.add(text)
                        if (text.text) text = newElement(elementType)
                        text = renderGraceNoteNames(cursor, trailingFifo, text, true, movableDoOffset, notationIndex, placementIndex, cursor.segment, displayModeIndex, unisonLabelPositionIndex, currentTrack, trackState)
                    }
                    cursor.next()
                }
            }
        }
        cursor.rewind(1)
    }
    
    function getElementTick(element) {
        var segment = element;
        while (segment.parent && segment.type != Element.SEGMENT) segment = segment.parent;
        return segment.tick;
    }

    onRun: {
        var keysig_potential = 0;
        var cursor = curScore.newCursor();
        if(curScore.selection.isRange) {
            cursor.rewind(Cursor.SELECTION_START);
        } else {
            cursor.rewind(Cursor.SCORE_START);
            for (var i in curScore.selection.elements) {
                var element = curScore.selection.elements[i];
                cursor.rewindToTick(getElementTick(element));
                cursor.track = element.track;
                break;
            }
        }
        keysig_potential = cursor.keySignature;
        while(keysig_potential < -7) keysig_potential += 12
        while(keysig_potential > +7) keysig_potential -= 12
        tonality.currentIndex = 7 - keysig_potential
    }

    width: form.width
    height: form.height

    Item {
        id: form
        width: exporterColumn.width + 30
        height: exporterColumn.height + 30
        ColumnLayout {
            id: exporterColumn
            width: grid.width + 32
            Column {
                id: grid
                spacing: 16
                width: dialogControlWidth
                anchors.fill: parent
                anchors.margins: 16
                
                Column {
                    spacing: 6
                    StyledTextLabel { text: qsTr('Tonality') }
                    StyledDropdown {
                        id: tonality
                        width: dialogControlWidth
                        model: ["+7 C♯/a♯", "+6 F♯/d♯", "+5 B/g♯", "+4 E/c♯", "+3 A/f♯", "+2 D/b", "+1 G/e", "0 C/a", "-1 F/d", "-2 B♭/g", "-3 E♭/c", "-4 A♭/f", "-5 D♭/b♭", "-6 G♭/e♭", "-7 C♭/a♭"]
                        currentIndex: 7
                        onActivated: function(index, value) { currentIndex = index }
                    }
                }
                
                Column {
                    spacing: 6
                    StyledTextLabel { text: qsTr('Notation') }
                    StyledDropdown {
                        id: notation
                        width: dialogControlWidth
                        model: ["Letters-vowel", "Letters", "Numeric", "Solfege (Do Re Mi)"]
                        currentIndex: 3
                        onActivated: function(index, value) { currentIndex = index }
                    }
                }

                Column {
                    spacing: 6
                    StyledTextLabel { text: qsTr('Placement') }
                    StyledDropdown {
                        id: placementDir
                        width: dialogControlWidth
                        model: ["Above Staff", "Below Staff"]
                        currentIndex: 1 
                        onActivated: function(index, value) { currentIndex = index }
                    }
                }

                Column {
                    spacing: 6
                    StyledTextLabel { text: qsTr('Display Mode') }
                    StyledDropdown {
                        id: displayMode
                        width: dialogControlWidth
                        model: ["All Notes", "Unison Only"]
                        currentIndex: 0
                        onActivated: function(index, value) { currentIndex = index }
                    }
                }

                Column {
                    spacing: 6
                    StyledTextLabel { text: qsTr('Unison Label Position') }
                    StyledDropdown {
                        id: unisonLabelPosition
                        width: dialogControlWidth
                        model: ["Above Note Name", "Below Note Name"]
                        currentIndex: 1
                        onActivated: function(index, value) { currentIndex = index }
                    }
                }

                FlatButton {
                    id: button
                    width: dialogControlWidth
                    text: qsTr("OK")
                    onClicked: {
                        curScore.startCmd()
                        nameNotesMovableDo(tonality.currentText, notation.currentIndex, placementDir.currentIndex, displayMode.currentIndex, unisonLabelPosition.currentIndex)
                        curScore.endCmd()
                        _quit()
                    }
                }
            }
        }
    }

    Settings {
        id: settings
        category: "MovableDoFingeringPlugin"
        property alias notation: notation.currentIndex
        property alias placement: placementDir.currentIndex
        property alias displayMode: displayMode.currentIndex
        property alias unisonLabelPosition: unisonLabelPosition.currentIndex
    }
}
