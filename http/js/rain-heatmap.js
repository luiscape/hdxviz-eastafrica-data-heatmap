// heatmap
var cal = new CalHeatMap();
cal.init({
	itemSelector: "#rain-heatmap",
	domain : "month",			// Group data by month
	subDomain : "day",
	data: "data/datas-years.json",
	start: new Date(2000, 0),
	// cellSize: 9,
	range: 8,
	previousSelector: "#menos-dias",
	nextSelector: "#mais-dias",
	scale: [40, 60, 10000, 200000],
	legendColors: {
		empty: "#cccccc",
		min: "#f1eef6",
		max: "#045a8d"
	}
});