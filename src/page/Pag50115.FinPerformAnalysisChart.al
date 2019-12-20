page 50115 "Fin. Perform. Analysis Chart"
{
    Caption = 'Financial Performance';
    DeleteAllowed = false;
    PageType = CardPart;
    SourceTable = "Business Chart Buffer";

    layout
    {
        area(content)
        {
            field(StatusText; 'General Ledger')
            {
                ApplicationArea = All;
                Caption = 'Status Text';
                ShowCaption = false;
                Style = StrongAccent;
                StyleExpr = true;
                ToolTip = 'Specifies the status of the cash flow forecast.';
            }
            usercontrol(BusinessChart; "Microsoft.Dynamics.Nav.Client.BusinessChart")
            {
                ApplicationArea = All;

                trigger DataPointClicked(point: JsonObject)
                var

                begin
                    FinPerformChartMgt.ChartDrillDown(point);
                end;

                trigger AddInReady()
                begin
                    FinPerformChartMgt.OnOpenPage(FinPerformChartSetup);
                    // UpdateStatus;
                    IsChartAddInReady := true;
                    if IsChartAddInReady then
                        UpdateChart(Period);
                end;

                trigger Refresh()
                begin
                    // NeedsUpdate := true;
                    If IsChartAddInReady and IsChartDataReady then
                        UpdateChart(Period);
                end;
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(PeriodLength)
            {
                Caption = 'Period Length';
                Image = Period;

                action(Day)
                {
                    ApplicationArea = All;
                    Caption = 'Day';
                    Image = DueDate;
                    ToolTip = 'Each stack covers one day.';

                    trigger OnAction()
                    begin
                        FinPerformChartSetup.SetPeriodLength(FinPerformChartSetup."Period Length"::Day);
                        UpdateChart(Period);
                    end;
                }
                action(Week)
                {
                    ApplicationArea = All;
                    Caption = 'Week';
                    Image = DateRange;
                    ToolTip = 'Show entries summed for one week.';

                    trigger OnAction()
                    begin
                        FinPerformChartSetup.SetPeriodLength(FinPerformChartSetup."Period Length"::Week);
                        UpdateChart(Period);
                    end;
                }
                action(Month)
                {
                    ApplicationArea = All;
                    Caption = 'Month';
                    Image = DateRange;
                    ToolTip = 'Each stack stack covers one month.';

                    trigger OnAction()
                    begin
                        FinPerformChartSetup.SetPeriodLength(FinPerformChartSetup."Period Length"::Month);
                        UpdateChart(Period);
                    end;
                }
                action(Quarter)
                {
                    ApplicationArea = All;
                    Caption = 'Quarter';
                    Image = DateRange;
                    ToolTip = 'Show amounts for each quarter.';

                    trigger OnAction()
                    begin
                        FinPerformChartSetup.SetPeriodLength(FinPerformChartSetup."Period Length"::Quarter);
                        UpdateChart(Period);
                    end;
                }
                action(Year)
                {
                    ApplicationArea = All;
                    Caption = 'Year';
                    Image = DateRange;
                    ToolTip = 'Show amounts summed for one year.';

                    trigger OnAction()
                    begin
                        FinPerformChartSetup.SetPeriodLength(FinPerformChartSetup."Period Length"::Year);
                        UpdateChart(Period);
                    end;
                }
            }
            action(PreviousPeriod)
            {
                ApplicationArea = All;
                Caption = 'Previous Period';
                // Enabled = PreviousNextActionEnabled;
                Image = PreviousRecord;
                ToolTip = 'Show the information based on the previous period. If you set the View by field to Day, the date filter changes to the day before.';

                trigger OnAction()
                begin
                    UpdateChart(Period::Previous);
                    // BusinessChartBuffer.Update(CurrPage.BusinessChart);
                end;
            }
            action(NextPeriod)
            {
                ApplicationArea = All;
                Caption = 'Next Period';
                // Enabled = PreviousNextActionEnabled;
                Image = NextRecord;
                ToolTip = 'Show the information based on the next period.';

                trigger OnAction()
                begin
                    UpdateChart(Period::Next);
                    // BusinessChartBuffer.Update(CurrPage.BusinessChart);
                end;
            }
            action(ChartInformation)
            {
                ApplicationArea = All;
                Caption = 'Chart Information';
                Image = AboutNav;
                ToolTip = 'View a description of the chart.';

                trigger OnAction()
                begin
                    Message(ChartDescriptionMsg);
                end;
            }
        }
        //}
    }
    trigger OnFindRecord(Which: Text): Boolean
    begin
        // Commenting out these lines fixed the refresh/updates chart twice when you change period, or select other actions.
        // UpdateChart(Period);
        // IsChartDataReady := true;
    end;

    local procedure UpdateChart(Period: Option)
    begin
        if not IsChartAddInReady then
            exit;
        if FinPerformChartMgt.UpdateChartData(Rec, Period) then begin
            Update(CurrPage.BusinessChart);
        end;
    end;

    // local procedure UpdateStatus()
    // begin
    //     NeedsUpdate := NeedsUpdate;
    //     if not NeedsUpdate then
    //         exit;

    //     //OldCashFlowChartSetup := CashFlowChartSetup;
    //     //StatusText := CashFlowChartSetup.GetCurrentSelectionText;
    // end;

    var
        FinPerformChartMgt: Codeunit "Fin. Perform. Chart Mgmt";
        FinPerformChartSetup: Record "Fin. Perform. Chart Setup";
        StatusText: Text;
        NeedsUpdate: Boolean;
        ChartDescriptionMsg: Label 'Shows the amounts in the general ledger.';
        Period: Option " ",Next,Previous;
        [InDataSet]
        IsChartDataReady: Boolean;
        IsChartAddInReady: Boolean;
        IsCashFlowSetUp: Boolean;

}

