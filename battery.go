package main

import (
	"errors"
	"math"

	"github.com/distatus/battery"
	mp "github.com/mackerelio/go-mackerel-plugin"
)

// BatteryPlugin battery plugin for Mackerel.
type BatteryPlugin struct{}

// GraphDefinition returns the graph definition.
func (p BatteryPlugin) GraphDefinition() map[string]mp.Graphs {
	return map[string]mp.Graphs{
		"battery.capacity": {
			Label: "Battery Capacity / mAh",
			Unit:  mp.UnitFloat,
			Metrics: []mp.Metrics{
				{Name: "design", Label: "Design capacity"},
				{Name: "max", Label: "Max capacity"},
				{Name: "current", Label: "Current capacity"},
			},
		},
		"battery.percentage": {
			Label: "Battery Capacity / %",
			Unit:  mp.UnitPercentage,
			Metrics: []mp.Metrics{
				{Name: "current_per_max", Label: "Current per max capacity"},
			},
		},
		"battery.voltage": {
			Label: "Battery Voltage / V",
			Unit:  mp.UnitFloat,
			Metrics: []mp.Metrics{
				{Name: "current_voltage", Label: "Current voltage"},
			},
		},
	}
}

// FetchMetrics returns the metrics.
func (p BatteryPlugin) FetchMetrics() (map[string]float64, error) {
	bat, err := battery.Get(0)

	var errPartial battery.ErrPartial
	if err != nil && !errors.As(err, &errPartial) {
		return nil, err
	}

	if errPartial.Design != nil {
		bat.Design = math.NaN()
	}
	if errPartial.Voltage != nil {
		bat.Voltage = math.NaN()
	}
	if errPartial.Full != nil {
		bat.Full = math.NaN()
	}
	if errPartial.Current != nil {
		bat.Current = math.NaN()
	}

	metrics := map[string]float64{
		"design":          bat.Design / bat.Voltage,
		"max":             bat.Full / bat.Voltage,
		"current":         bat.Current / bat.Voltage,
		"current_per_max": bat.Current / bat.Full * 100,
		"current_voltage": bat.Voltage,
	}
	for k, v := range metrics {
		if math.IsNaN(v) {
			delete(metrics, k)
		}
	}

	return metrics, nil
}

func main() {
	mp.NewMackerelPlugin(BatteryPlugin{}).Run()
}
