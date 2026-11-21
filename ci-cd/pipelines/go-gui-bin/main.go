package main

import (
	"fyne.io/fyne/v2"
	"fyne.io/fyne/v2/app"
	"fyne.io/fyne/v2/container"
	"fyne.io/fyne/v2/widget"
)

func main() {
	a := app.New()
	w := a.NewWindow("Go GUI Bin")

	name := widget.NewEntry()
	name.SetPlaceHolder("Имя")
	label := widget.NewLabel(greeting(""))

	button := widget.NewButton("Приветствовать", func() {
		label.SetText(greeting(name.Text))
	})

	w.SetContent(container.NewVBox(name, button, label))
	w.Resize(fyne.NewSize(320, 160))
	w.ShowAndRun()
}
