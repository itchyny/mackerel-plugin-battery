package main

import (
	"errors"

	"github.com/distatus/battery"
	mp "github.com/mackerelio/go-mackerel-plugin"
)

// BatteryPlugin battery plugin for Mackerel.
type BatteryPlugin struct{}

// GraphDefinition returns the graph definition.
func (p BatteryPlugin) GraphDefinition() map[string]mp.Graphs {
	return map[string]mp.Graphs{
		"battery.capacity": {
			Label: "Battery Capacity mAh",
			Unit:  mp.UnitFloat,
			Metrics: []mp.Metrics{
				{Name: "design", Label: "Design capacity"},
				{Name: "max", Label: "Max capacity"},
				{Name: "current", Label: "Current capacity"},
			},
		},
		"battery.percentage": {
			Label: "Battery Capacity %",
			Unit:  mp.UnitPercentage,
			Metrics: []mp.Metrics{
				{Name: "current_per_max", Label: "Current per max capacity"},
			},
		},
	}
}

// FetchMetrics returns the metrics.
func (p BatteryPlugin) FetchMetrics() (map[string]float64, error) {
	batteries, err := battery.GetAll()
	if err != nil {
		return nil, err
	}
	if len(batteries) == 0 {
		return nil, errors.New("battery not found")
	}
	battery := batteries[0]
	return map[string]float64{
		"design":          battery.Design / battery.Voltage,
		"max":             battery.Full / battery.Voltage,
		"current":         battery.Current / battery.Voltage,
		"current_per_max": battery.Current / battery.Full * 100,
	}, nil
}

func main() {
	mp.NewMackerelPlugin(BatteryPlugin{}).Run()
}
