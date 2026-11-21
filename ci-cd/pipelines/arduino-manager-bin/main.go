package main

import (
	"fyne.io/fyne/v2"
	"fyne.io/fyne/v2/app"
	"fyne.io/fyne/v2/container"
	"fyne.io/fyne/v2/widget"
)

var sampleBoards = []string{
	"/dev/ttyACM0 arduino:avr:uno Arduino Uno",
	"/dev/ttyUSB0 esp32:esp32:esp32 ESP32 Dev Module",
}

func main() {
	a := app.New()
	w := a.NewWindow("Arduino Manager")

	list := widget.NewList(
		func() int { return len(sampleBoards) },
		func() fyne.CanvasObject {
			return widget.NewLabel("board")
		},
		func(id widget.ListItemID, obj fyne.CanvasObject) {
			board, ok := ParseBoardLine(sampleBoards[id])
			if !ok {
				return
			}
			obj.(*widget.Label).SetText(board.Name + " — " + board.Port)
		},
	)

	refresh := widget.NewButton("Обновить", func() {
		list.Refresh()
	})

	w.SetContent(container.NewBorder(refresh, nil, nil, nil, list))
	w.Resize(fyne.NewSize(480, 320))
	w.ShowAndRun()
}
