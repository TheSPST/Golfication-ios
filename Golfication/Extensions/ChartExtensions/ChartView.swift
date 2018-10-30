//
//  ChartView.swift
//  Golfication
//
//  Created by IndiRenters on 10/31/17.
//  Copyright © 2017 Khelfie. All rights reserved.
//

import UIKit
import Charts
import Foundation
let FONT_SIZE :CGFloat = 12.0
let MAX_BAR_WIDTH = 0.2
extension RadarChartView{
    
    func setChart(dataPoints: [String], values: [Double],chartView :RadarChartView) {
        chartView.noDataText = "No data available."
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(x: Double(i) , y: values[i])
            dataEntries.append(dataEntry)
        }
        let chartDataSet = RadarChartDataSet(values: dataEntries, label: "")
        //Options of radarChart
        chartView.sizeToFit()
        chartView.chartDescription?.text = ""
        chartDataSet.drawFilledEnabled = true
        chartDataSet.fillColor = UIColor.glfFlatBlue75.withAlphaComponent(0.25)
        chartDataSet.colors = [UIColor.glfFlatBlue]
        chartDataSet.valueColors = [UIColor.clear]
        //Other options
        chartView.yAxis.gridAntialiasEnabled = true
        chartView.animate(yAxisDuration: 2.0)
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: dataPoints)
        //Also, you probably want to add:
        chartView.xAxis.granularity = 1
        //Then set data
        let chartData = RadarChartData(dataSet: chartDataSet)
        chartView.data = chartData
        chartView.xAxis.labelFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        chartView.xAxis.labelTextColor = UIColor.glfBlack50
        
        chartView.yAxis.labelFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        chartView.yAxis.labelTextColor = UIColor.clear
        chartView.isUserInteractionEnabled = false
        
    }
}
extension CombinedChartView{
    func setBarChartWithLines(dataPoints: [String], values: [Double],legend:[String], chartView :CombinedChartView ,color : UIColor, barWidth:Double){
        chartView.noDataText = "No data available."
        var yVals1 : [ChartDataEntry] = [ChartDataEntry]()
        var dataEntriesFor18Hole: [ChartDataEntry] = []
        var dataEntriesFor09Hole: [ChartDataEntry] = []
        
        var xAxisLabel:[String] = []
        
        for i in 0..<dataPoints.count {
            if(legend[i] == "18 holes"){
                let dataEntry = BarChartDataEntry(x: Double(i), y: values[i])
                dataEntriesFor18Hole.append(dataEntry)
                
            }
            else{
                let dataEntry = BarChartDataEntry(x: Double(i), y: values[i])
                dataEntriesFor09Hole.append(dataEntry)
                
            }
            yVals1.append(ChartDataEntry(x: Double(i), y:values[i] ))
            xAxisLabel.append(dataPoints[i]) // shubham
        }
        let chartDataSet = BarChartDataSet(values: dataEntriesFor18Hole, label: "" )
        chartDataSet.setColor(color)
        var entriesOfLegends = [LegendEntry]()
        if(dataEntriesFor18Hole.count>0){
            let entry = LegendEntry()
            entry.formColor = color
            entry.label = "18 Holes"
            entriesOfLegends.append(entry)
        }
        
        let chartDataSet2 = BarChartDataSet(values: dataEntriesFor09Hole, label: "")
        chartDataSet2.setColor(UIColor.glfBluegreen)
        if(dataEntriesFor09Hole.count>0){
            let entry2 = LegendEntry()
            entry2.formColor = UIColor.glfBluegreen
            entry2.label = "9 Holes"
            entriesOfLegends.append(entry2)
        }

        let lineChartSet = LineChartDataSet(values: yVals1, label: "")
        
        let data: CombinedChartData = CombinedChartData(dataSets: [lineChartSet,chartDataSet,chartDataSet2])

        
        data.barData = BarChartData(dataSets:[chartDataSet,chartDataSet2])
        data.lineData = LineChartData(dataSets:[lineChartSet])
        lineChartSet.lineDashLengths = [5.0]
        lineChartSet.circleRadius = 1.0
        data.barData.barWidth = barWidth
        chartView.data = data
        chartView.legend.enabled = true
        chartView.legend.horizontalAlignment = .right
        chartView.legend.verticalAlignment = .top
        if(entriesOfLegends.count > 0){
            chartView.legend.setCustom(entries: entriesOfLegends)
        }
        chartView.chartDescription?.text = ""
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.axisMinimum = -0.5
        chartView.xAxis.axisMaximum = Double(dataPoints.count) - 0.5
        chartView.xAxis.labelCount = dataPoints.count
//        chartView.xAxis.wordWrapEnabled = true
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.rightAxis.enabled = false
        chartView.leftAxis.enabled = true
        chartView.leftAxis.labelFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        chartView.leftAxis.labelTextColor = UIColor.glfWarmGrey
        chartView.xAxis.labelFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        chartView.xAxis.labelTextColor = UIColor.glfWarmGrey
        chartView.leftAxis.axisMinimum = 0.0
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:dataPoints)
//        chartView.xAxis.labelCount = dataPoints.count + 1
        chartView.leftAxis.labelCount = 3
        chartView.data?.setDrawValues(false)
//        barChartSet.setColor(color)
        lineChartSet.setColor(color)
        chartView.leftAxis.axisLineColor = UIColor.clear
        chartView.xAxis.axisLineColor = UIColor.clear
        chartView.leftAxis.gridColor = UIColor.glfBlack5
        chartView.xAxis.wordWrapEnabled = false
        chartView.xAxis.labelCount = 5
        chartView.isUserInteractionEnabled = false
    }
    func setBarChartWithOutLines(dataPoints: [String], values: [Double],legend:[String], chartView :CombinedChartView ,color : UIColor, barWidth:Double) {
        chartView.noDataText = "No data available."
        
        var yVals1 : [ChartDataEntry] = [ChartDataEntry]()
        var dataEntriesFor18Hole: [ChartDataEntry] = []
        var dataEntriesFor09Hole: [ChartDataEntry] = []
        
        var xAxisLabel:[String] = []
        
        for i in 0..<dataPoints.count {
            if(legend[i] == "18 holes"){
                let dataEntry = BarChartDataEntry(x: Double(i), y: values[i])
                dataEntriesFor18Hole.append(dataEntry)
                
            }
            else{
                let dataEntry = BarChartDataEntry(x: Double(i), y: values[i])
                dataEntriesFor09Hole.append(dataEntry)
                
            }
            yVals1.append(ChartDataEntry(x: Double(i), y:values[i] ))
            xAxisLabel.append(dataPoints[i]) // shubham
        }
        let chartDataSet = BarChartDataSet(values: dataEntriesFor18Hole, label: "" )
        chartDataSet.setColor(color)
        var entriesOfLegends = [LegendEntry]()
        if(dataEntriesFor18Hole.count>0){
            let entry = LegendEntry()
            entry.formColor = color
            entry.label = "18 Holes"
            entriesOfLegends.append(entry)
        }
        
        let chartDataSet2 = BarChartDataSet(values: dataEntriesFor09Hole, label: "")
        chartDataSet2.setColor(UIColor.glfBluegreen)
        if(dataEntriesFor09Hole.count>0){
            let entry2 = LegendEntry()
            entry2.formColor = UIColor.glfBluegreen
            entry2.label = "9 Holes"
            entriesOfLegends.append(entry2)
        }
        
//        let lineChartSet = LineChartDataSet(values: yVals1, label: "")
        
        let data: CombinedChartData = CombinedChartData(dataSets: [chartDataSet,chartDataSet2])
        
        
        data.barData = BarChartData(dataSets:[chartDataSet,chartDataSet2])
//        data.lineData = LineChartData(dataSets:[lineChartSet])
//        lineChartSet.lineDashLengths = [5.0]
//        lineChartSet.circleRadius = 1.0
        data.barData.barWidth = barWidth
        chartView.data = data
        chartView.legend.enabled = true
        chartView.legend.horizontalAlignment = .right
        chartView.legend.verticalAlignment = .top
        if(entriesOfLegends.count > 0){
            chartView.legend.setCustom(entries: entriesOfLegends)
        }
        chartView.chartDescription?.text = ""
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.axisMinimum = -0.5
        chartView.xAxis.axisMaximum = Double(dataPoints.count) - 0.5
        chartView.xAxis.labelCount = dataPoints.count
        //        chartView.xAxis.wordWrapEnabled = true
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.rightAxis.enabled = false
        chartView.leftAxis.enabled = true
        chartView.leftAxis.labelFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        chartView.leftAxis.labelTextColor = UIColor.glfWarmGrey
        chartView.xAxis.labelFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        chartView.xAxis.labelTextColor = UIColor.glfWarmGrey
        chartView.leftAxis.axisMinimum = 0.0
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:dataPoints)
        //        chartView.xAxis.labelCount = dataPoints.count + 1
        chartView.leftAxis.labelCount = 3
        chartView.data?.setDrawValues(false)
        //        barChartSet.setColor(color)
//        lineChartSet.setColor(color)
        chartView.leftAxis.axisLineColor = UIColor.clear
        chartView.xAxis.axisLineColor = UIColor.clear
        chartView.leftAxis.gridColor = UIColor.glfBlack5
        chartView.xAxis.wordWrapEnabled = false
        chartView.xAxis.labelCount = 5
        chartView.isUserInteractionEnabled = false
    }
    func setScatterChartWithLine(valueX: [Double], valueY: [Double],xAxisValue:[String], chartView :CombinedChartView ,color : UIColor) {
        
        chartView.noDataText = "No data available."
        
        var yVals1 : [ChartDataEntry] = [ChartDataEntry]()
        var yVals2 : [BarChartDataEntry] = [BarChartDataEntry]()
        var value = valueY
        var count = 0
        var colors = [UIColor]()
        var avgData = [Double]()

        for i in 0..<valueX.count {
            var avg = [Double]()
            for _ in 0..<Int(valueX[i]){
                let dataEntry = BarChartDataEntry(x: Double(i), y: value[count])
                avg.append(value[count])
                count += 1
                yVals2.append(dataEntry)
            }
            let sum = avg.reduce(0, +)
            yVals1.append(ChartDataEntry(x: Double(i), y:sum/Double(avg.count)))
            avgData.append(sum/Double(avg.count))
        }
        count = 0
        for i in 0..<valueX.count {
            for _ in 0..<Int(valueX[i]){
                if(avgData[i] > value[count]){
                    colors.append(color)
                }
                else{
                    colors.append(UIColor.glfRosyPink)
                }
                count += 1
            }
        }
        let formatter = NumberFormatter()
        formatter.positiveSuffix = " yd"
        if(distanceFilter == 1){
            formatter.positiveSuffix = " m"
        }
        let lineChartSet = LineChartDataSet(values: yVals1, label: "")
        let scatterChartSet: ScatterChartDataSet = ScatterChartDataSet(values: yVals2, label: "")
        let data: CombinedChartData = CombinedChartData(dataSets: [lineChartSet,scatterChartSet])
        scatterChartSet.setScatterShape(.circle)
        scatterChartSet.colors = colors
        data.scatterData = ScatterChartData(dataSets:[scatterChartSet])
        data.lineData = LineChartData(dataSets:[lineChartSet])
        //        lineChartSet.lineDashLengths = [5.0]
        lineChartSet.circleRadius = 1.0
        lineChartSet.mode = .cubicBezier

        chartView.data = data
        chartView.legend.enabled = false
        chartView.chartDescription?.text = ""
        chartView.xAxis.labelPosition = .bottom
        chartView.leftAxis.gridColor = UIColor.glfBlack5
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.rightAxis.enabled = false
        chartView.leftAxis.enabled = true
        chartView.leftAxis.labelFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        chartView.leftAxis.labelTextColor = UIColor.glfWarmGrey
        chartView.leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter:formatter)
        chartView.xAxis.labelFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        chartView.xAxis.labelTextColor = UIColor.glfWarmGrey
        chartView.leftAxis.labelCount = value.count/2
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:xAxisValue)
        chartView.xAxis.granularity = 1
        chartView.xAxis.axisMinimum = -0.5
        chartView.xAxis.axisMaximum = Double(data.allData.count*2) - 0.5
//        chartView.leftAxis.axisMaximum = (value.max() ?? 0.0) + (value.max() ?? 0.0)*0.1
        chartView.leftAxis.labelCount = 4
//        chartView.leftAxis.axisMinimum = 100.0
        chartView.data?.setDrawValues(false)
        lineChartSet.setColor(color)
        chartView.leftAxis.axisLineColor = UIColor.clear
        chartView.xAxis.axisLineColor = UIColor.clear
        chartView.isUserInteractionEnabled = false
        chartView.xAxis.wordWrapEnabled = false
        chartView.xAxis.labelCount = 5
        chartView.isUserInteractionEnabled = false
    }
    func setScatterChartWithLineOnlyDriveDistance(valueX: [Double], valueY: [Double],xAxisValue:[String], chartView :CombinedChartView ,color : UIColor) {
        
        chartView.noDataText = "No data available."
        
        var yVals1 : [ChartDataEntry] = [ChartDataEntry]()
        var yVals2 : [BarChartDataEntry] = [BarChartDataEntry]()
        var value = valueY
        var count = 0
        var colors = [UIColor]()
        var avgData = [Double]()
        
        for i in 0..<valueX.count {
            var avg = [Double]()
            for _ in 0..<Int(valueX[i]){
                let dataEntry = BarChartDataEntry(x: Double(i), y: value[count])
                avg.append(value[count])
                count += 1
                yVals2.append(dataEntry)
            }
            let sum = avg.reduce(0, +)
            yVals1.append(ChartDataEntry(x: Double(i), y:sum/Double(avg.count)))
            avgData.append(sum/Double(avg.count))
        }
        count = 0
        for i in 0..<valueX.count {
            for _ in 0..<Int(valueX[i]){
                if(avgData[i] > value[count]){
                    colors.append(UIColor.glfRosyPink)
                }
                else{
                    colors.append(color)
                }
                count += 1
            }
        }
        let formatter = NumberFormatter()
        formatter.positiveSuffix = " yd"
        if(distanceFilter == 1){
            formatter.positiveSuffix = " m"
        }
        let lineChartSet = LineChartDataSet(values: yVals1, label: "")
        let scatterChartSet: ScatterChartDataSet = ScatterChartDataSet(values: yVals2, label: "")
        let data: CombinedChartData = CombinedChartData(dataSets: [lineChartSet,scatterChartSet])
        scatterChartSet.setScatterShape(.circle)
        scatterChartSet.colors = colors
        data.scatterData = ScatterChartData(dataSets:[scatterChartSet])
        data.lineData = LineChartData(dataSets:[lineChartSet])
        //        lineChartSet.lineDashLengths = [5.0]
        lineChartSet.circleRadius = 1.0
        lineChartSet.mode = .cubicBezier
        
        chartView.data = data
        chartView.legend.enabled = false
        chartView.chartDescription?.text = ""
        chartView.xAxis.labelPosition = .bottom
        chartView.leftAxis.gridColor = UIColor.glfBlack5
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.rightAxis.enabled = false
        chartView.leftAxis.enabled = true
        chartView.leftAxis.labelFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        chartView.leftAxis.labelTextColor = UIColor.glfWarmGrey
        chartView.leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter:formatter)
        chartView.xAxis.labelFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        chartView.xAxis.labelTextColor = UIColor.glfWarmGrey
        chartView.leftAxis.labelCount = value.count/2
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:xAxisValue)
        chartView.xAxis.granularity = 1
        chartView.xAxis.axisMinimum = -0.5
        chartView.xAxis.axisMaximum = Double(data.allData.count*2) - 0.5
        //        chartView.leftAxis.axisMaximum = (value.max() ?? 0.0) + (value.max() ?? 0.0)*0.1
        chartView.leftAxis.labelCount = 4
        //        chartView.leftAxis.axisMinimum = 100.0
        chartView.data?.setDrawValues(false)
        lineChartSet.setColor(color)
        chartView.leftAxis.axisLineColor = UIColor.clear
        chartView.xAxis.axisLineColor = UIColor.clear
        chartView.isUserInteractionEnabled = false
        chartView.xAxis.wordWrapEnabled = false
        chartView.xAxis.labelCount = 5
        chartView.isUserInteractionEnabled = false
    }
}
extension PieChartView {
    // Function to set the PieChartView
    func setChart(dataPoints: [String], values: [Double], chartView :PieChartView ) {
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let dataEntry1 = ChartDataEntry(x: Double(i), y: values[i], data: dataPoints[i] as AnyObject)
            dataEntries.append(dataEntry1)
        }
        let pieChartDataSet = PieChartDataSet(values: dataEntries, label: "")
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        chartView.data = pieChartData
        chartView.legend.enabled = false
        chartView.holeRadiusPercent = 0
        pieChartDataSet.selectionShift = 0
        chartView.highlightPerTapEnabled = false
        chartView.transparentCircleColor = UIColor.clear
        chartView.chartDescription?.text = ""
        
        var colors: [UIColor] = []
        for _ in 0..<dataPoints.count {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
        pieChartDataSet.colors = colors
        chartView.animate(yAxisDuration: 1.3, easingOption: ChartEasingOption.easeOutBack)
        chartView.isUserInteractionEnabled = false
        chartView.noDataText = "No data available."

    }
    func setHalfPieChart(dataPoints:[String],values:[Double],chartView:PieChartView){
        var dataEntries = [ChartDataEntry]()
        for (_,value) in values.enumerated() {
            let entry = ChartDataEntry()
            entry.y = value
            dataEntries.append(entry)
        }
        let pieChartDataSet = PieChartDataSet(values: dataEntries, label: "")
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        chartView.usePercentValuesEnabled = true
        chartView.drawSlicesUnderHoleEnabled = true
        chartView.holeRadiusPercent = 0
        chartView.chartDescription?.enabled = false
        chartView.drawCenterTextEnabled = false
        chartView.drawEntryLabelsEnabled = false
        chartView.legend.enabled = false
        chartView.rotationAngle = 180
        chartView.maxAngle = 180;
        chartView.data = pieChartData
        pieChartDataSet.colors = [UIColor.red,UIColor.glfBlueyGreen,UIColor.red]
        chartView.animate(yAxisDuration: 1.3, easingOption: ChartEasingOption.easeOutBack)
        chartView.isUserInteractionEnabled = false
        chartView.noDataText = "No data available."

    }
    
    func setChartForScoring(dataPoints: [String], values: [Double], chartView :PieChartView,color:UIColor,isValueEnable:Bool) {
        var dataEntries = [PieChartDataEntry]()
        for (index, value) in values.enumerated() {
            if(value != 0){
                let entry = PieChartDataEntry()
                entry.y = value
                entry.label = dataPoints[index]
                dataEntries.append(entry)
            }
        }
        
        let pieChartDataSet = PieChartDataSet(values: dataEntries, label: "")
        pieChartDataSet.xValuePosition = .outsideSlice
        pieChartDataSet.yValuePosition = .outsideSlice
        pieChartDataSet.sliceSpace = 2.0
        pieChartDataSet.valueLineWidth = 0.01
        pieChartDataSet.selectionShift = 5.0
        pieChartDataSet.valueLinePart2Length = 2.0
        pieChartDataSet.valueTextColor = UIColor(red: 58.0/255.0, green: 124.0 / 255.0, blue: 149.0 / 255.0, alpha: 1)
        pieChartDataSet.valueLineColor = UIColor.clear
        pieChartDataSet.valueLineVariableLength = true
        
        
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        chartView.data = pieChartData
        chartView.drawEntryLabelsEnabled = isValueEnable
        chartView.holeRadiusPercent = 0
        chartView.usePercentValuesEnabled = true
        chartView.highlightPerTapEnabled = false
        chartView.transparentCircleColor = UIColor.clear
        chartView.legend.enabled = false
        chartView.chartDescription?.text = ""
        let formatter = NumberFormatter()
        formatter.positiveSuffix = "%"
        formatter.zeroSymbol = ""
        pieChartDataSet.valueFormatter = DefaultValueFormatter(formatter:formatter)
        var colors: [UIColor] = []
        for i in 0..<dataPoints.count {
            var alpha = CGFloat(values[i]/100)
            alpha = alpha + 0.25
            if(alpha > 1){
                alpha = 1.0
            }
            let colorWithPerc = color.withAlphaComponent(alpha)
            colors.append(colorWithPerc)
        }
        pieChartDataSet.colors = colors
        chartView.animate(yAxisDuration: 1.3, easingOption: ChartEasingOption.easeOutBack)
        chartView.isUserInteractionEnabled = false
        chartView.noDataText = "No data available."

    }
    func setChartForPuttingBreak(dataPoints: [String], values: [Double], chartView :PieChartView, avgPutts:Double) {
        var dataEntries = [PieChartDataEntry]()
        for (index, value) in values.enumerated() {
            let entry = PieChartDataEntry()
            entry.y = value
            entry.label = dataPoints[index]
            dataEntries.append(entry)
        }
        
        let pieChartDataSet = PieChartDataSet(values: dataEntries, label: "")
        pieChartDataSet.xValuePosition = .outsideSlice
        let formatter = NumberFormatter()
//        formatter.roundingMode = .ceiling
//        formatter.numberStyle = .none
        formatter.positiveSuffix = "%"
        pieChartDataSet.valueFormatter = DefaultValueFormatter(formatter:formatter)
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        chartView.data = pieChartData
        chartView.centerText = "\(avgPutts) putts\nper round"
        chartView.usePercentValuesEnabled = true
        chartView.highlightPerTapEnabled = false
        chartView.transparentCircleColor = UIColor.clear
        chartView.legend.enabled = true
        chartView.legend.horizontalAlignment = .left
        chartView.legend.verticalAlignment = .top
        chartView.chartDescription?.text = ""
        chartView.drawEntryLabelsEnabled = false
        var colors: [UIColor] = []
        for i in 0..<dataPoints.count {
            if(dataPoints[i] == "0 Putt"){
                colors.append(UIColor.glfBluegreen75)
            }
            else if(dataPoints[i] == "1 Putt"){
                colors.append(UIColor.glfPaleTealTwo)
            }
            else if(dataPoints[i] == "2 Putt"){
                colors.append(UIColor.glfLightBlueGrey)
            }
            else if(dataPoints[i] == "3 Putt"){
                colors.append(UIColor.glfRosyPink)
            }
            else if(dataPoints[i] == "4 Putt"){
                colors.append(UIColor.glfDustyRed)
            }
        }
        if(colors.count != 0){
            pieChartDataSet.colors = colors
        }
        chartView.animate(yAxisDuration: 1.3, easingOption: ChartEasingOption.easeOutBack)
        chartView.isUserInteractionEnabled = false
        chartView.noDataText = "No data available."

    }
    func setChartForPractice(dataPoints: [String], values: [Double], chartView :PieChartView, avgPutts:Double) {
        var dataEntries = [PieChartDataEntry]()
        for (index, value) in values.enumerated() {
            let entry = PieChartDataEntry()
            entry.y = value
            entry.label = dataPoints[index]
            dataEntries.append(entry)
        }
        
        let pieChartDataSet = PieChartDataSet(values: dataEntries, label: "")
        pieChartDataSet.xValuePosition = .outsideSlice
        let formatter = NumberFormatter()
        //        formatter.roundingMode = .ceiling
        //        formatter.numberStyle = .none
        formatter.positiveSuffix = "%"
        pieChartDataSet.valueFormatter = DefaultValueFormatter(formatter:formatter)
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        chartView.data = pieChartData
        chartView.centerText = "\(avgPutts)°"
        chartView.usePercentValuesEnabled = true
        chartView.highlightPerTapEnabled = false
        chartView.transparentCircleColor = UIColor.clear
        chartView.legend.enabled = true
        chartView.legend.horizontalAlignment = .left
        chartView.legend.verticalAlignment = .top
        chartView.chartDescription?.text = ""
        chartView.drawEntryLabelsEnabled = false
        var colors: [UIColor] = []
        for i in 0..<dataPoints.count {
            if(dataPoints[i] == "0 Putt"){
                colors.append(UIColor.glfBluegreen75)
            }
            else if(dataPoints[i] == "1 Putt"){
                colors.append(UIColor.glfPaleTealTwo)
            }
            else if(dataPoints[i] == "2 Putt"){
                colors.append(UIColor.glfLightBlueGrey)
            }
            else if(dataPoints[i] == "3 Putt"){
                colors.append(UIColor.glfRosyPink)
            }
            else if(dataPoints[i] == "4 Putt"){
                colors.append(UIColor.glfDustyRed)
            }
        }
        if(colors.count != 0){
            pieChartDataSet.colors = colors
        }
        chartView.animate(yAxisDuration: 1.3, easingOption: ChartEasingOption.easeOutBack)
        chartView.isUserInteractionEnabled = false
        chartView.noDataText = "No data available."
        
    }
}

extension HorizontalBarChartView{
    func drawHorizontalBarChart(dataPoints: [String], values: [Double], chartView :HorizontalBarChartView,colors:[UIColor], barWidth:Double) {
        var dataEntries = [ChartDataEntry]()
        for i in 0..<values.count {
            //            let entry = BarChartDataEntry(x: values[i], yValues: [Double(i)])
            let entry = BarChartDataEntry(x: values[i], y:Double(i+1)) // Changed on 16Feb18
            dataEntries.append(entry)
        }
        let barChartDataSet = BarChartDataSet(values: dataEntries, label: "")
        barChartDataSet.drawValuesEnabled = false
        barChartDataSet.colors = colors
        
        let barChartData = BarChartData(dataSet: barChartDataSet)
        barChartData.barWidth = barWidth
        chartView.leftAxis.gridColor = UIColor.clear
        chartView.xAxis.gridColor = UIColor.clear
        //        chartView.rightAxis.axisLineColor = UIColor.clear
        chartView.rightAxis.gridColor = UIColor.clear
        
        chartView.rightAxis.labelFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        chartView.rightAxis.labelTextColor = UIColor.glfWarmGrey
        chartView.leftAxis.drawAxisLineEnabled = false
        chartView.xAxis.labelFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        chartView.xAxis.labelTextColor = UIColor.glfWarmGrey
        chartView.rightAxis.axisMaximum = 5
        chartView.rightAxis.axisMinimum = 0
        chartView.rightAxis.labelCount = 5
        //        chartView.rightAxis.drawLabelsEnabled = false
        chartView.leftAxis.drawLabelsEnabled = false
        chartView.xAxis.drawLabelsEnabled = false
        chartView.xAxis.drawAxisLineEnabled = false
        chartView.data = barChartData
        chartView.legend.enabled = false
        chartView.drawGridBackgroundEnabled = false
        chartView.chartDescription?.text = ""
        chartView.isUserInteractionEnabled = false
        chartView.noDataText = "No data available."

    }
}

extension BarChartView {
    // Function to set the BarChartView
    func setBarChart(dataPoints: [String], values: [Double], chartView :BarChartView,color : UIColor, barWidth:Double,leftAxisMinimum:Int,labelTextColor:UIColor,unit:String,valueColor : UIColor) {
        var dataEntries: [ChartDataEntry] = []
        var colors = [UIColor]()
        for i in 0..<dataPoints.count {
            if !dataPoints[i].contains("Pu"){
                let dataEntry = BarChartDataEntry(x: Double(i), y: values[i])
                if(values[i] < 0){
                    colors.append(UIColor.white)
                }
                else{
                    colors.append(color)
                }
                dataEntries.append(dataEntry)
            }
        }
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "" )
        let chartData = BarChartData(dataSet: chartDataSet)
        chartView.data = chartData
        chartView.xAxis.wordWrapEnabled = true
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.leftAxis.gridColor = labelTextColor.withAlphaComponent(0.25)
        chartView.leftAxis.axisLineColor = UIColor.clear
        chartView.xAxis.axisLineColor = UIColor.clear
        
        chartView.leftAxis.axisMinimum = Double(leftAxisMinimum)

        chartData.barWidth = barWidth
        let formatter = NumberFormatter()
        formatter.positiveSuffix = unit
        
        //remove coloured box
        chartView.legend.enabled = false
        chartView.drawGridBackgroundEnabled = false
        //remove chartDescriptions
        chartView.chartDescription?.text = ""
        chartView.xAxis.labelPosition = .bottom
        chartView.rightAxis.enabled = false
        chartView.leftAxis.enabled = true
        chartView.leftAxis.labelFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        chartView.leftAxis.labelTextColor = labelTextColor//UIColor.glfWhite.withAlphaComponent(0.5)
        chartView.xAxis.labelCount = dataPoints.count
        chartDataSet.valueFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        chartDataSet.valueFormatter = DefaultValueFormatter(formatter:formatter)
        chartDataSet.valueColors = [valueColor]
        chartView.xAxis.labelFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        chartView.xAxis.labelTextColor = labelTextColor //UIColor.glfWhite.withAlphaComponent(0.5)
        
//        let formatter = NumberFormatter()
        
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:dataPoints)
        chartView.xAxis.granularity = 1
        
        chartView.data?.setDrawValues(true)
        chartDataSet.colors = colors
        chartView.xAxis.labelCount = 5
        chartView.xAxis.wordWrapEnabled = false
        chartView.isUserInteractionEnabled = false
        chartView.noDataText = "No data available."

    }
    func setBarChartForTogether(dataPoints: [String], values: [Double], chartView :BarChartView,color : UIColor, barWidth:Double,whichValue:Int) {
        var dataEntries: [ChartDataEntry] = []
        var colors = [UIColor]()
        for i in 0..<values.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: values[i])
            if(i < whichValue){
                colors.append(UIColor.white)
            }
            else{
                colors.append(UIColor.glfWarmGrey)
            }
            dataEntries.append(dataEntry)
        }
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "" )
        let chartData = BarChartData(dataSet: chartDataSet)
        chartView.data = chartData
        chartView.xAxis.wordWrapEnabled = true
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.leftAxis.axisLineColor = UIColor.clear
        chartView.xAxis.axisLineColor = UIColor.clear
        chartData.barWidth = barWidth
        let formatter = NumberFormatter()
        //remove coloured box
        chartView.legend.enabled = false
        chartView.drawGridBackgroundEnabled = false
        //remove chartDescriptions
        chartView.chartDescription?.text = ""
        chartView.xAxis.labelPosition = .bottom
        chartView.rightAxis.enabled = false
        chartView.leftAxis.enabled = true
        chartView.leftAxis.labelFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        chartView.leftAxis.labelTextColor = UIColor.glfWhite.withAlphaComponent(0.5)
        chartView.xAxis.labelCount = dataPoints.count
        chartDataSet.valueFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        chartDataSet.valueFormatter = DefaultValueFormatter(formatter:formatter)
        chartDataSet.valueColors = [UIColor.glfWhite]
        chartView.xAxis.labelFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        chartView.xAxis.labelTextColor = UIColor.glfWhite.withAlphaComponent(0.5)
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:dataPoints)
        chartView.xAxis.granularity = 1
        chartView.data?.setDrawValues(true)
        chartDataSet.colors = colors
        chartView.isUserInteractionEnabled = false
        chartView.noDataText = "No data available."

    }
    func setBarChartStrokesGained(dataPoints: [String], values: [Double], chartView :BarChartView,color : UIColor, barWidth:Double,valueColor:UIColor) {
        var dataEntries: [ChartDataEntry] = []
        var colors = [UIColor]()
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: values[i])
            if(values[i] < 0){
                colors.append(UIColor.glfRosyPink)
            }
            else{
                colors.append(color)
            }
            dataEntries.append(dataEntry)
        }
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "" )
        chartDataSet.valueFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        chartDataSet.valueColors = [valueColor]

        let chartData = BarChartData(dataSet: chartDataSet)
        chartView.data = chartData
        chartView.xAxis.wordWrapEnabled = true
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.leftAxis.axisLineColor = UIColor.clear

        chartData.barWidth = barWidth
        chartView.leftAxis.gridColor = UIColor.glfBlack5
        
        //remove coloured box
        chartView.legend.enabled = false
        
        //remove chartDescriptions
        chartView.chartDescription?.text = ""
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.labelCount = dataPoints.count
        
        chartView.rightAxis.enabled = false
        chartView.leftAxis.enabled = true
        chartView.leftAxis.labelCount = 3
        
        chartView.leftAxis.labelFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        chartView.leftAxis.labelTextColor = UIColor.glfWarmGrey
        
        chartView.xAxis.labelFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        chartView.xAxis.labelTextColor = UIColor.glfWarmGrey
        chartView.xAxis.axisLineColor = UIColor.clear

        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:dataPoints)
        chartView.xAxis.granularity = 1
        
        chartView.data?.setDrawValues(true)
        chartDataSet.colors = colors
        chartView.isUserInteractionEnabled = false
        chartView.noDataText = "No data available."

    }
    
    
    
    
    func setBarChartPuttsVSHandicap(dataPoints: [String], values: [Double], chartView :BarChartView,colors:[UIColor], barWidth:Double) {
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
        }
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "" )
        let chartData = BarChartData(dataSet: chartDataSet)
        chartView.data = chartData
        chartView.xAxis.wordWrapEnabled = true
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.leftAxis.axisLineColor = UIColor.clear

        chartData.barWidth = barWidth
        
        //remove coloured box
        chartView.legend.enabled = false
        
        //remove chartDescriptions
        chartView.chartDescription?.text = ""
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.labelCount = dataPoints.count
        
        chartView.rightAxis.enabled = false
        chartView.leftAxis.enabled = true
        chartView.leftAxis.labelFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        chartView.leftAxis.labelTextColor = UIColor.glfWarmGrey
        chartView.xAxis.labelFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        chartView.xAxis.labelTextColor = UIColor.glfWarmGrey
        chartView.leftAxis.gridColor = UIColor.glfBlack5

        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:dataPoints)
        chartView.xAxis.granularity = 1
        chartView.xAxis.axisLineColor = UIColor.clear

        chartView.data?.setDrawValues(true)
        chartDataSet.colors = colors
        chartView.isUserInteractionEnabled = false
        chartView.noDataText = "No data available."

    }
    // set bar chart with range
    
    func setBarChartWithRange(dataPoints: [String], minimum: [Double],maximum:[Double] ,chartView :BarChartView,color : [UIColor],barWidth:Double) {
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<dataPoints.count {
            if(maximum[i] != minimum[i]) && !dataPoints[i].contains("Pu"){
                let entry1 = BarChartDataEntry(x: Double(i), yValues: [minimum[i],maximum[i]-minimum[i]])
                dataEntries.append(entry1)
            }
        }
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "" )
        chartDataSet.drawValuesEnabled = false
        let chartData = BarChartData(dataSet: chartDataSet)
        chartView.data = chartData
        chartView.xAxis.wordWrapEnabled = true
        chartView.xAxis.drawGridLinesEnabled = false
        chartData.barWidth = barWidth
        chartView.leftAxis.axisMinimum = 0.0
        //remove coloured box
        chartView.legend.enabled = false
        //remove chartDescriptions
        chartView.chartDescription?.text = ""
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.labelCount = dataPoints.count
        chartView.drawGridBackgroundEnabled = false
        chartView.leftAxis.axisLineColor = UIColor.clear

        chartView.rightAxis.enabled = false
        chartView.leftAxis.enabled = true
        chartView.xAxis.axisLineColor = UIColor.clear


        chartView.leftAxis.labelFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        chartView.leftAxis.labelTextColor = UIColor.glfWarmGrey
        chartView.xAxis.labelFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        chartView.xAxis.labelTextColor = UIColor.glfWarmGrey
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:dataPoints)
        chartView.xAxis.granularity = 1
        chartView.leftAxis.gridColor = UIColor.glfBlack5
        chartDataSet.colors = color
        chartView.isUserInteractionEnabled = false
        chartView.noDataText = "No data available."

    }
    // Stacked Bar Charts
    func setStackedBarChart(dataPoints: [String], value1: [Double], value2: [Double],  chartView :BarChartView,color : [UIColor],barWidth:Double) {
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<dataPoints.count {
            if !(value1[i] == 0 && value2[i] == 0){
                let dataEntry = BarChartDataEntry(x: Double(i), y: value1[i])
                let dataEntry2 = BarChartDataEntry(x:Double(i), y: value2[i])
                dataEntries.append(dataEntry)
                dataEntries.append(dataEntry2)
            }
        }
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "" )
        let chartData = BarChartData(dataSet: chartDataSet)
        chartView.data = chartData
        chartView.xAxis.drawGridLinesEnabled = false
        chartDataSet.drawValuesEnabled = false
        chartView.leftAxis.axisMinimum = 0.0
        chartData.barWidth = barWidth
        //remove coloured box
        chartView.legend.enabled = false
        //remove chartDescriptions
        chartView.chartDescription?.text = ""
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.labelCount = dataPoints.count
        chartView.leftAxis.axisLineColor = UIColor.clear
        chartView.xAxis.axisLineColor = UIColor.clear
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        chartDataSet.valueFormatter = DefaultValueFormatter(formatter:formatter)
        chartView.rightAxis.enabled = false
        chartView.leftAxis.enabled = true
        chartView.leftAxis.labelFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        chartView.leftAxis.labelTextColor = UIColor.glfWarmGrey
        chartView.xAxis.labelFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        chartView.xAxis.labelTextColor = UIColor.glfWarmGrey
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:dataPoints)
        chartView.xAxis.granularity = 1
        chartView.leftAxis.gridColor = UIColor.glfBlack5
        chartView.data?.setDrawValues(true)
        chartDataSet.colors = color
        chartView.xAxis.wordWrapEnabled = false
        chartView.xAxis.labelCount = 5
        chartView.isUserInteractionEnabled = false
        chartView.noDataText = "No data available."


    }
    func setStackedBarChart(dataPoints: [String], value1: [Double],chartView :BarChartView,barWidth:Double ) {
        var dataEntriesPositive: [BarChartDataEntry] = []
        var dataEntriesNegetive: [BarChartDataEntry] = []
        var dataEntriesDefault: [BarChartDataEntry] = []
        dataEntriesDefault.append(BarChartDataEntry(x: 0, y: 3))
        dataEntriesDefault.append(BarChartDataEntry(x: 1, y: 4))
        dataEntriesDefault.append(BarChartDataEntry(x: 2, y: 5))
        
        if(value1[0] > 3){
            dataEntriesPositive.append(BarChartDataEntry(x: 0, y: value1[0]))
        }
        else{
            dataEntriesNegetive.append(BarChartDataEntry(x: 0, y: value1[0]))
        }
        if(value1[1] > 4){
            dataEntriesPositive.append(BarChartDataEntry(x: 1, y: value1[1]))
        }
        else{
            dataEntriesNegetive.append(BarChartDataEntry(x: 1, y: value1[1]))
        }
        if(value1[2] > 5){
            dataEntriesPositive.append(BarChartDataEntry(x: 2, y: value1[2]))
        }
        else{
            dataEntriesNegetive.append(BarChartDataEntry(x: 2, y: value1[2]))
        }
        
        let chartDataSetPositive = BarChartDataSet(values: dataEntriesPositive, label: "")
        chartDataSetPositive.colors = [UIColor.glfRosyPink]
        
        let chartDataSetNegetive = BarChartDataSet(values: dataEntriesNegetive, label: "")
        chartDataSetNegetive.colors = [UIColor.glfLightBlueGrey]
        
        let chartDataSetDefault = BarChartDataSet(values: dataEntriesDefault, label: "")
        chartDataSetDefault.colors = [UIColor.glfPaleTeal]
        chartDataSetDefault.drawValuesEnabled = false
        chartView.leftAxis.axisLineColor = UIColor.clear

        
        chartView.xAxis.wordWrapEnabled = false
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.leftAxis.axisMinimum = 0.0
        chartView.leftAxis.axisMaximum = 8.0
        chartDataSetPositive.valueFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        chartDataSetNegetive.valueFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        chartDataSetDefault.valueFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        chartDataSetPositive.valueTextColor = UIColor.glfWarmGrey
        
        chartView.legend.enabled = false
        //remove chartDescriptions
        chartView.chartDescription?.text = ""
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.labelCount = dataPoints.count
        chartView.xAxis.axisLineColor = UIColor.clear

        chartView.rightAxis.enabled = false
        chartView.leftAxis.enabled = true
        chartView.leftAxis.labelFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        chartView.leftAxis.labelTextColor = UIColor.glfWarmGrey
        chartView.xAxis.labelFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        chartView.xAxis.labelTextColor = UIColor.glfWarmGrey
        //        chartView.leftAxis.valueFormatter = IndexAxisValueFormatter().perce
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:dataPoints)
        chartView.xAxis.granularity = 1
        chartView.leftAxis.gridColor = UIColor.glfBlack5

        let chartData = BarChartData(dataSets: [chartDataSetPositive,chartDataSetDefault,chartDataSetNegetive])
        chartData.barWidth = barWidth
        chartView.data = chartData
        chartView.xAxis.labelCount = 5
        chartView.isUserInteractionEnabled = false
        chartView.noDataText = "No data available."

        
    }
    
    func setBarChartGameType(dataPoints: [String],values :[Double], gameType: [String], chartView :BarChartView,barWidth:Double ) {
        var dataEntriesFor18Hole: [ChartDataEntry] = []
        var dataEntriesFor09Hole: [ChartDataEntry] = []

        var xAxisLabel:[String] = []

        for i in 0..<dataPoints.count {
            if(gameType[i] == "18 holes"){
                let dataEntry = BarChartDataEntry(x: Double(i), yValues: [values[i]])
                dataEntriesFor18Hole.append(dataEntry)

            }
            else{
                let dataEntry = BarChartDataEntry(x: Double(i), yValues: [values[i]])
                dataEntriesFor09Hole.append(dataEntry)

            }
            xAxisLabel.append(dataPoints[i]) // shubham
        }
        let chartDataSet = BarChartDataSet(values: dataEntriesFor18Hole, label: "" )
        chartDataSet.setColor(UIColor.glfSeafoamBlue)
        chartDataSet.label = "18 Holes"
        
        let chartDataSet2 = BarChartDataSet(values: dataEntriesFor09Hole, label: "")
        chartDataSet2.setColor(UIColor.glfWhite)
        chartDataSet2.label = "9 Holes"

        let chartData = BarChartData(dataSets: [chartDataSet,chartDataSet2])
        chartView.data = chartData
        chartView.legend.textColor = UIColor.glfWhite
        chartView.xAxis.wordWrapEnabled = true
        chartView.xAxis.drawGridLinesEnabled = false
        chartData.barWidth = barWidth
        chartDataSet.valueFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        chartDataSet.valueColors = [UIColor.glfWhite.withAlphaComponent(0.25)]
        //coloured box
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        chartDataSet.valueFormatter = DefaultValueFormatter(formatter:formatter)
        chartDataSet2.valueFormatter = DefaultValueFormatter(formatter:formatter)
        chartDataSet2.valueFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        chartDataSet2.valueColors = [UIColor.glfWhite.withAlphaComponent(0.25)]

        chartView.leftAxis.labelFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        chartView.leftAxis.labelTextColor = UIColor.glfWhite.withAlphaComponent(0.5)
        chartView.xAxis.labelFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        chartView.xAxis.labelTextColor = UIColor.glfWhite.withAlphaComponent(0.5)

        
        
        chartView.legend.enabled = true
        chartView.legend.horizontalAlignment = .right
        chartView.legend.verticalAlignment = .top
        chartView.leftAxis.axisLineColor = UIColor.clear
        chartView.xAxis.axisLineColor = UIColor.clear

        //remove chartDescriptions
        chartView.chartDescription?.text = ""
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.labelCount = dataPoints.count
        chartView.leftAxis.labelCount = 5
        chartView.rightAxis.enabled = false
        chartView.leftAxis.enabled = true
        chartView.xAxis.granularity = 1
        chartView.data?.setDrawValues(true)
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:xAxisLabel)
        chartDataSet.stackLabels = gameType
        chartView.leftAxis.gridColor = UIColor.glfWhite.withAlphaComponent(0.05)

        chartView.leftAxis.axisMinimum = 0
//        chartView.leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter:formatter)
        chartView.xAxis.granularity = 1
        chartView.xAxis.labelCount = 5
        chartView.xAxis.wordWrapEnabled = false
        chartView.isUserInteractionEnabled = false
        chartView.noDataText = "No data available."

    }
}
extension ScatterChartView {
    func setScatterChart(valueX: [Double], valueY: [Double], chartView :ScatterChartView,color:[UIColor]) {
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<valueY.count {
            let dataEntry = BarChartDataEntry(x: valueX[i], y: valueY[i])
            dataEntries.append(dataEntry)
        }
        let chartDataSet = ScatterChartDataSet(values: dataEntries, label: "")
        chartView.data = ScatterChartData(dataSet: chartDataSet)
        chartDataSet.setScatterShape(.circle)
        chartDataSet.scatterShapeSize = 5.0
//        chartDataSet.setColor(color)
        chartDataSet.colors = color
        //        chartDataSet.scatterShapeHoleRadius = 1.0
        chartDataSet.drawValuesEnabled = false
//         = chartData
        chartView.xAxis.enabled = true
        chartView.legend.enabled = false
        chartView.chartDescription?.text = ""
        chartView.xAxis.labelPosition = .bottom
        chartView.leftAxis.labelCount = 3
        chartView.rightAxis.enabled = false
        chartView.leftAxis.enabled = true
        chartView.leftAxis.labelFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        chartView.leftAxis.labelTextColor = UIColor.glfWarmGrey
        chartView.xAxis.labelFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        chartView.xAxis.labelTextColor = UIColor.glfWarmGrey
        
        chartView.xAxis.axisMinimum = -55;
        chartView.xAxis.axisMaximum = 55;
        chartView.leftAxis.axisLineColor = UIColor.clear
        chartView.xAxis.axisLineColor = UIColor.clear
        chartView.isUserInteractionEnabled = false
        chartView.noDataText = "No data available."

    }
    func setScatterChartWithLegend(valueX: [Double], valueY: [Double], dataPoints:[String],chartView :ScatterChartView,color:[UIColor],userData:[Int]) {
        chartView.noDataText = "No data available."

            var dataEntries: [ChartDataEntry] = []
        var totalColors = [UIColor]()
        var count = 0
        for i in 0..<userData.count {
            for _ in 0..<Int(userData[i]){
                let dataEntry = BarChartDataEntry(x: valueX[count], y: valueY[count])
                count += 1
                dataEntries.append(dataEntry)
                totalColors.append(color[i])
            }
            
        }
            let chartDataSet = ScatterChartDataSet(values: dataEntries, label: "")
            chartDataSet.setScatterShape(.circle)
            chartDataSet.scatterShapeSize = 10.0
            chartDataSet.drawValuesEnabled = false
            chartView.data = ScatterChartData(dataSet: chartDataSet)
            chartDataSet.colors = totalColors


        //         = chartData
        chartView.xAxis.enabled = true
        chartView.legend.enabled = false
        chartView.legend.horizontalAlignment = .right
        chartView.legend.verticalAlignment = .top
        chartView.chartDescription?.text = ""
        chartView.xAxis.labelPosition = .bottom
//        chartView.leftAxis.
        
        chartView.rightAxis.enabled = false
        chartView.leftAxis.enabled = true
        chartView.leftAxis.labelFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        chartView.leftAxis.labelTextColor = UIColor.glfWarmGrey
        chartView.xAxis.labelFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        chartView.xAxis.labelTextColor = UIColor.glfWarmGrey
        chartView.leftAxis.gridColor = UIColor.clear
        chartView.xAxis.gridColor = UIColor.clear
        chartView.xAxis.axisMinimum = -55;
        chartView.xAxis.axisMaximum = 55;
        chartView.leftAxis.axisLineColor = UIColor.clear
        chartView.xAxis.axisLineColor = UIColor.clear
        chartView.isUserInteractionEnabled = false
    }
    func setScatterChartForDistance(label:[String], valueX: [Double], valueY: [Double], chartView :ScatterChartView,color:UIColor ) {
        var dataEntries: [ChartDataEntry] = []
        var value = valueY
        var count = 0
        for i in 0..<valueX.count {
            for _ in 0..<Int(valueX[i]){
                let dataEntry = BarChartDataEntry(x: Double(i), y: value[count])
                count += 1
                dataEntries.append(dataEntry)
            }
            
        }
        let chartDataSet = ScatterChartDataSet(values: dataEntries, label: "")
        let chartData = ScatterChartData(dataSet: chartDataSet)
        chartDataSet.setScatterShape(.circle)
        chartView.data = chartData
        chartView.legend.enabled = false
        chartView.chartDescription?.text = ""
        chartView.xAxis.labelPosition = .bottom
        chartDataSet.scatterShapeSize = 3.0
        chartDataSet.setColor(color)
        chartDataSet.drawValuesEnabled = false
        
        chartView.rightAxis.enabled = false
        chartView.leftAxis.enabled = true
        chartView.leftAxis.labelFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        chartView.leftAxis.labelTextColor = UIColor.glfWarmGrey
        chartView.xAxis.labelFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        chartView.xAxis.labelTextColor = UIColor.glfWarmGrey
        
        chartView.backgroundColor = UIColor.glfBlueyGreen
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:label)
        chartView.xAxis.granularity = 1
        chartView.leftAxis.axisMaximum = (valueY.max() ?? 0.0) + (valueY.max() ?? 0.0)*0.1
        chartView.leftAxis.axisLineColor = UIColor.clear
        chartView.xAxis.axisLineColor = UIColor.clear
        chartView.isUserInteractionEnabled = false
        chartView.noDataText = "No data available."

        
    }
    func setScatterChartForDistanceWithoutLabel(valueX: [Double], valueY: [Double], chartView :ScatterChartView ,color:UIColor) {
        var dataEntries: [ChartDataEntry] = []
        var value = valueY
        var count = 0
        for i in 0..<valueX.count {
            for _ in 0..<Int(valueX[i]){
                let dataEntry = BarChartDataEntry(x: Double(i), y: value[count])
                count += 1
                dataEntries.append(dataEntry)
            }
            
        }
        let chartDataSet = ScatterChartDataSet(values: dataEntries, label: "")
        let chartData = ScatterChartData(dataSet: chartDataSet)
        chartDataSet.setScatterShape(.circle)
        
        chartView.data = chartData
        chartView.legend.enabled = false
        chartView.chartDescription?.text = ""
        chartView.xAxis.labelPosition = .bottom
        chartDataSet.scatterShapeSize = 3.0
        chartDataSet.setColor(color)
        chartDataSet.drawValuesEnabled = false
        chartView.leftAxis.gridColor = UIColor.glfBlack5

        chartView.rightAxis.enabled = false
        chartView.leftAxis.enabled = true
        chartView.leftAxis.labelFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        chartView.leftAxis.labelTextColor = UIColor.glfWarmGrey
        chartView.xAxis.labelFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        chartView.xAxis.labelTextColor = UIColor.glfWarmGrey
        chartView.leftAxis.axisMaximum = (valueY.max() ?? 0.0) + (valueY.max() ?? 0.0 )*0.1
        chartView.leftAxis.axisLineColor = UIColor.clear
        chartView.xAxis.axisLineColor = UIColor.clear
        chartView.isUserInteractionEnabled = false
        chartView.noDataText = "No data available."

    }
    
}

extension LineChartView {
    // Function to set the LineChartView
    func setLineChart(dataPoints: [String], values: [Double], chartView :LineChartView ) {
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(x: Double(i), yValues: [values[i]])
            dataEntries.append(dataEntry)
        }
        let chartDataSet = LineChartDataSet(values: dataEntries, label: "")
        var dataSets = [IChartDataSet]()
        dataSets.append(chartDataSet)
        
        let chartData = LineChartData(dataSets: dataSets)
        
        // let chartData = LineChartData(xValues:dataPoints, dataSet: chartDataSet)
        chartView.data = chartData
        chartView.xAxis.wordWrapEnabled = true
        chartView.xAxis.drawGridLinesEnabled = false
        chartDataSet.mode = .cubicBezier
        let gradientColors = [UIColor(red: CGFloat(0/255), green: CGFloat(176/255), blue: CGFloat(255/255), alpha: 1).cgColor, UIColor.clear.cgColor] as CFArray // Colors of the gradient
        let colorLocations:[CGFloat] = [1.0, 0.0] // Positioning of the gradient
        let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations) // Gradient Object
        chartDataSet.fill = Fill.fillWithLinearGradient(gradient!, angle: 90.0) // Set the Gradient
        chartDataSet.drawFilledEnabled = true
        chartDataSet.drawCirclesEnabled=false
        chartDataSet.cubicIntensity = 0.2
        chartView.xAxis.enabled = true
        chartView.legend.enabled = false
        chartView.chartDescription?.text = ""
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.labelCount = dataPoints.count
        chartView.leftAxis.axisLineColor = UIColor.clear
        chartView.xAxis.axisLineColor = UIColor.clear
        chartView.leftAxis.gridColor = UIColor.glfBlack5

        chartView.rightAxis.enabled = false
        chartView.leftAxis.enabled = true
        chartView.leftAxis.labelFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        chartView.leftAxis.labelTextColor = UIColor.glfWarmGrey
        chartView.xAxis.labelFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        chartView.xAxis.labelTextColor = UIColor.glfWarmGrey
        
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:dataPoints)
        chartView.xAxis.granularity = 1
        chartView.noDataText = "No data available."

        chartView.data?.setDrawValues(true)
        chartView.isUserInteractionEnabled = false
    }
    func setLineChartWithColor(dataPoints: [String], values: [Double], chartView :LineChartView,color:UIColor ) {
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(x: Double(i), yValues: [values[i]])
            dataEntries.append(dataEntry)
        }
        let chartDataSet = LineChartDataSet(values: dataEntries, label: "")
        
        var dataSets = [IChartDataSet]()
        dataSets.append(chartDataSet)
        
        let chartData = LineChartData(dataSets: dataSets)
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 1
        formatter.multiplier = 1.0
        // let chartData = LineChartData(xValues:dataPoints, dataSet: chartDataSet)
        chartView.data = chartData
        chartView.xAxis.wordWrapEnabled = true
        chartView.xAxis.drawGridLinesEnabled = false
        //        chartDataSet.mode = .cubicBezier
        let gradientColors = [UIColor(red: CGFloat(58/255), green: CGFloat(125/255), blue: CGFloat(165/255), alpha: 1).cgColor, UIColor.clear.cgColor] as CFArray // Colors of the gradient
        let colorLocations:[CGFloat] = [1.0, 0.0] // Positioning of the gradient
        let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations) // Gradient Object
        chartDataSet.fill = Fill.fillWithLinearGradient(gradient!, angle: 90.0) // Set the Gradient
        chartDataSet.drawFilledEnabled = true
        chartDataSet.lineDashLengths = [5.0]
        chartDataSet.circleRadius = 4.0
        chartDataSet.circleHoleRadius = 2.0
        chartDataSet.setColor(color)
        chartDataSet.circleColors = [color]
        chartView.xAxis.enabled = true
        chartView.legend.enabled = false
        chartView.chartDescription?.text = ""
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.labelCount = dataPoints.count
        chartDataSet.drawValuesEnabled = false
        chartView.leftAxis.axisMinimum = 0.0
        chartView.rightAxis.enabled = false
        chartView.leftAxis.enabled = true
        chartView.leftAxis.labelFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        chartView.leftAxis.labelTextColor = UIColor.glfWarmGrey
        chartView.leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter:formatter)
        chartView.leftAxis.axisLineColor = UIColor.clear
        chartView.xAxis.axisLineColor = UIColor.clear
        chartView.leftAxis.gridColor = UIColor.glfBlack5

        chartView.xAxis.labelFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        chartView.xAxis.labelTextColor = UIColor.glfWarmGrey
        chartView.noDataText = "No data available."

        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:dataPoints)
        chartView.xAxis.granularity = 1
        chartView.isUserInteractionEnabled = false
    }
    func setLineChartSimple(dataPoints: [String], values: [Double], chartView :LineChartView ,color:UIColor) {
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
        }
        let chartDataSet = LineChartDataSet(values: dataEntries, label: "")
        var dataSets = [IChartDataSet]()
        dataSets.append(chartDataSet)
        
        let chartData = LineChartData(dataSets: dataSets)
        chartDataSet.lineDashLengths = [5.0]
        chartDataSet.circleRadius = 4.0
        chartDataSet.circleHoleRadius = 2.0
        chartDataSet.setColor(color)
        chartDataSet.circleColors = [color]
        chartDataSet.drawCirclesEnabled = true
        chartDataSet.drawValuesEnabled = false
        
        chartView.data = chartData
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.xAxis.enabled = true
        chartView.legend.enabled = false
        chartView.chartDescription?.text = ""
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.labelCount = dataPoints.count
        chartView.leftAxis.gridColor = UIColor.glfBlack5
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 1
        formatter.multiplier = 1.0
        
        chartView.rightAxis.enabled = false
        chartView.leftAxis.enabled = true
        chartView.leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter:formatter)
        
        chartView.leftAxis.labelFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        chartView.leftAxis.labelTextColor = UIColor.glfWarmGrey
        chartView.xAxis.labelFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        chartView.xAxis.labelTextColor = UIColor.glfWarmGrey
        chartView.leftAxis.axisLineColor = UIColor.clear
        chartView.xAxis.axisLineColor = UIColor.clear

        chartView.noDataText = "No data available."

        chartView.leftAxis.axisMinimum = 0
        chartView.leftAxis.axisMaximum = 100
        chartView.leftAxis.setLabelCount(5, force: true)
        
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:dataPoints)
        chartView.xAxis.granularity = 1
        chartView.isUserInteractionEnabled = false
    }
    
    func setLineChartHandSpeed(dataPoints: [String], values: [Double], chartView :LineChartView,color:UIColor ) {
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(x: Double(i), yValues: [values[i]])
            dataEntries.append(dataEntry)
        }
        let chartDataSet = LineChartDataSet(values: dataEntries, label: "")
        
        var dataSets = [IChartDataSet]()
        dataSets.append(chartDataSet)
        
        let chartData = LineChartData(dataSets: dataSets)
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .percent
//        formatter.maximumFractionDigits = 1
//        formatter.multiplier = 1.0
        // let chartData = LineChartData(xValues:dataPoints, dataSet: chartDataSet)
        chartView.data = chartData
        chartView.xAxis.wordWrapEnabled = true
        chartView.xAxis.drawGridLinesEnabled = false
        chartDataSet.mode = .cubicBezier
        let gradientColors = [color.cgColor, UIColor.white.cgColor] as CFArray // Colors of the gradient
        let colorLocations:[CGFloat] = [1.0, 0.0] // Positioning of the gradient
        let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations) // Gradient Object
        chartDataSet.fill = Fill.fillWithLinearGradient(gradient!, angle: 90.0) // Set the Gradient
        chartDataSet.drawFilledEnabled = true
        chartDataSet.setColor(color)
        chartDataSet.circleRadius = 0.0
        chartDataSet.circleColors = [color]
        chartView.xAxis.enabled = true
        chartView.legend.enabled = false
        chartView.chartDescription?.text = ""
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.labelCount = dataPoints.count
        chartDataSet.drawValuesEnabled = false
        chartView.leftAxis.axisMinimum = 0.0
        chartView.rightAxis.enabled = false
        chartView.leftAxis.enabled = true
        chartView.leftAxis.labelFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        chartView.leftAxis.labelTextColor = UIColor.clear
//        chartView.leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter:formatter)
        chartView.leftAxis.axisLineColor = UIColor.glfBlack50
        chartView.xAxis.axisLineColor = UIColor.glfBlack50
        chartView.leftAxis.gridColor = UIColor.clear
        
        chartView.xAxis.labelFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        chartView.xAxis.labelTextColor = UIColor.glfWarmGrey
        chartView.noDataText = "No data available."
        
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:dataPoints)
        chartView.xAxis.granularity = 1
        chartView.isUserInteractionEnabled = false
        
        chartView.animate(xAxisDuration: 2, easingOption: ChartEasingOption.easeOutBack)

    }
    func setCurveWithColor(dataPoints: Int, values: [[(x:Double,y:Double)]], chartView :LineChartView,color:[UIColor],playersName:[String],maxRange:Int ) {
        var dataSets = [IChartDataSet]()
        for i in 0..<dataPoints{
            var dataEntries: [ChartDataEntry] = []
            for j in 0..<values[i].count{
                let dataEntry = BarChartDataEntry(x:values[i][j].x , yValues:[values[i][j].y])
                dataEntries.append(dataEntry)
            }
            let chartDataSet = LineChartDataSet(values: dataEntries, label: playersName[i])
            chartDataSet.lineDashLengths = [5.0]
            chartDataSet.drawValuesEnabled = false
            chartDataSet.circleRadius = 0.0
            chartDataSet.circleHoleRadius = 0.0
            chartDataSet.setColor(color[i])
            dataSets.append(chartDataSet)
        }
        let chartData = LineChartData(dataSets: dataSets)
        // let chartData = LineChartData(xValues:dataPoints, dataSet: chartDataSet)
        chartView.data = chartData
        chartView.xAxis.drawGridLinesEnabled = false
        
        //        chartDataSet.circleColors = [color]
        chartView.xAxis.enabled = true
        chartView.legend.enabled = true
        chartView.legend.horizontalAlignment = .right
        chartView.legend.verticalAlignment = .top
        chartView.legend.direction = .leftToRight
        chartView.chartDescription?.text = ""
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.labelCount = 5
        chartView.xAxis.axisMinimum = 0
        chartView.xAxis.axisMaximum = Double(maxRange)
        chartView.leftAxis.axisMinimum = 0
        chartView.leftAxis.axisMaximum = 180
        chartView.rightAxis.enabled = false
        chartView.leftAxis.enabled = false
        chartView.xAxis.gridColor = UIColor.clear
        chartView.leftAxis.gridColor = UIColor.clear
        chartView.leftAxis.axisLineColor = UIColor.clear
        chartView.xAxis.axisLineColor = UIColor.glfWarmGrey
        chartView.leftAxis.labelFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        chartView.leftAxis.labelTextColor = UIColor.glfWarmGrey
        chartView.xAxis.labelFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        chartView.xAxis.labelTextColor = UIColor.glfWarmGrey
        let formatter = NumberFormatter()
        formatter.positiveSuffix = " yd"
        if(distanceFilter == 1){
            formatter.positiveSuffix = " m"
        }
        chartView.xAxis.valueFormatter = DefaultAxisValueFormatter(formatter:formatter)
        chartView.noDataText = "No data available."
        chartView.isUserInteractionEnabled = false
    }
    func setLineChartWithZigZag(dataPoints: Int, values: [[Double]], chartView :LineChartView,color:[UIColor] ,playersName:[String]) {
        var dataSets = [IChartDataSet]()
        for i in 0..<dataPoints{
            var dataEntries: [ChartDataEntry] = []
            for j in 0..<values[i].count{
                let dataEntry = BarChartDataEntry(x: Double(j+1), yValues: [values[i][j]])
                dataEntries.append(dataEntry)
            }
            let chartDataSet = LineChartDataSet(values: dataEntries, label: playersName[i])
            chartDataSet.mode = .stepped
            chartDataSet.drawValuesEnabled = false
            chartDataSet.circleRadius = 0.0
            chartDataSet.circleHoleRadius = 0.0
            chartDataSet.setColor(color[i])
            dataSets.append(chartDataSet)
        }
        let chartData = LineChartData(dataSets: dataSets)
        chartView.data = chartData
        chartView.xAxis.wordWrapEnabled = true
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.xAxis.enabled = true
        chartView.legend.enabled = true
        chartView.legend.horizontalAlignment = .right
        chartView.legend.verticalAlignment = .top
        
        chartView.chartDescription?.text = ""
        chartView.xAxis.labelPosition = .bottom
        chartView.noDataText = "No data available."
        
        chartView.rightAxis.enabled = false
        chartView.leftAxis.enabled = true
        chartView.xAxis.gridColor = UIColor.clear
        chartView.leftAxis.gridColor = UIColor.clear
        chartView.leftAxis.axisLineColor = UIColor.glfWarmGrey
        chartView.xAxis.axisLineColor = UIColor.glfWarmGrey
        chartView.leftAxis.labelFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        chartView.leftAxis.labelTextColor = UIColor.glfWarmGrey
        chartView.xAxis.labelFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        chartView.xAxis.labelTextColor = UIColor.glfWarmGrey
        chartView.xAxis.granularity = 1
        chartView.isUserInteractionEnabled = false
        
    }
    func setLineChartForMonsterPutt(values: [Double], chartView :LineChartView) {
        var dataSets = [IChartDataSet]()
        var dataEntries: [ChartDataEntry] = []


        for j in 0..<values.count{
            let dataEntry1 = ChartDataEntry(x: 0, y: 0)
            let dataEntry = ChartDataEntry(x: Double(j), y: values[j])
            dataEntries.append(dataEntry1)
            dataEntries.append(dataEntry)
        }
        let chartDataSet = LineChartDataSet(values: dataEntries, label: "")
        chartDataSet.mode = .linear
        chartDataSet.drawValuesEnabled = false
        chartDataSet.circleRadius = 0.0
        chartDataSet.circleHoleRadius = 0.0
        chartDataSet.setColor(UIColor.glfPaleTeal)
        dataSets.append(chartDataSet)
        
        let chartData = LineChartData(dataSets: dataSets)
        chartView.data = chartData
        chartView.xAxis.wordWrapEnabled = true
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.xAxis.enabled = true
        chartView.legend.enabled = false
        chartView.chartDescription?.text = ""
        chartView.xAxis.labelPosition = .bottom
        chartView.noDataText = "No data available."
        let formatter = NumberFormatter()
        formatter.roundingMode = .ceiling
        formatter.numberStyle = .none
        formatter.positiveSuffix = "ft"
        if(distanceFilter == 1){
            formatter.positiveSuffix = " m"
        }
        chartView.xAxis.valueFormatter = DefaultAxisValueFormatter(formatter:formatter)
        chartView.rightAxis.enabled = false
        chartView.leftAxis.enabled = false
        chartView.xAxis.gridColor = UIColor.clear
        chartView.leftAxis.gridColor = UIColor.clear
        chartView.leftAxis.axisLineColor = UIColor.clear
        chartView.xAxis.axisLineColor = UIColor.glfWarmGrey
        chartView.leftAxis.labelFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        chartView.leftAxis.labelTextColor = UIColor.glfWarmGrey
        chartView.xAxis.labelFont = UIFont(name: "SFProDisplay-Regular", size: FONT_SIZE)!
        chartView.xAxis.labelTextColor = UIColor.glfWarmGrey
        chartView.xAxis.granularity = 1
        chartView.isUserInteractionEnabled = false
        
    }
}
