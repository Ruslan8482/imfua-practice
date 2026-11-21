package main

import (
	"fmt"

	"fyne.io/fyne/v2"
	"fyne.io/fyne/v2/app"
	"fyne.io/fyne/v2/container"
	"fyne.io/fyne/v2/widget"
)

func main() {
	a := app.New()
	w := a.NewWindow("Hex Loader")

	input := widget.NewMultiLineEntry()
	input.SetPlaceHolder(":0300000001020304F7")
	status := widget.NewLabel("Введите строку Intel HEX")

	load := widget.NewButton("Загрузить", func() {
		record, err := ParseIntelHex(input.Text)
		if err != nil {
			status.SetText("Ошибка: " + err.Error())
			return
		}
		status.SetText(fmt.Sprintf(
			"Байт: %d, адрес: 0x%04X", record.ByteCount, record.Address,
		))
	})

	w.SetContent(container.NewVBox(input, load, status))
	w.Resize(fyne.NewSize(480, 260))
	w.ShowAndRun()
}
