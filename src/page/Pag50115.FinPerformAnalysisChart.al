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

                end;

                trigger AddInReady()
                begin
                    FinPerformChartMgt.OnOpenPage(FinPerformChartSetup);
                    // CashFlowChartMgt.OnOpenPage(CashFlowChartSetup);
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
            group("Chart Options")
            {
                Caption = 'Chart Options';
                group(PeriodLength)
                {
                    Caption = 'Period Length';
                    Image = Period;

                    action(Day)
                    {
                        ApplicationArea = All;
                        Caption = 'Day';
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
                        ToolTip = 'Show forecast entries summed for one week.';

                        trigger OnAction()
                        begin
                            FinPerformChartSetup.SetPeriodLength(FinPerformChartSetup."Period Length"::Week);
                            UpdateChart(Period);
                        end;
                    }
                    action(Month)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Month';
                        ToolTip = 'Each stack except for the last stack covers one month. The last stack contains data from the start of the month until the date that is defined by the Show option.';

                        trigger OnAction()
                        begin
                            FinPerformChartSetup.SetPeriodLength(FinPerformChartSetup."Period Length"::Month);
                            UpdateChart(Period);
                        end;
                    }
                    action(Quarter)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Quarter';
                        ToolTip = 'Each stack except for the last stack covers one quarter. The last stack contains data from the start of the quarter until the date that is defined by the Show option.';

                        trigger OnAction()
                        begin
                            FinPerformChartSetup.SetPeriodLength(FinPerformChartSetup."Period Length"::Quarter);
                            UpdateChart(Period);
                        end;
                    }
                    action(Year)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Year';
                        ToolTip = 'Show pending payments summed for one year. Overdue payments are shown as amounts within specific years from the due date going back five years from today''s date.';

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
                    ToolTip = 'Show the information based on the next period. If you set the View by field to Day, the date filter changes to the day before.';

                    trigger OnAction()
                    begin
                        // Period := Period::Next;
                        //FinPerformChartMgt.UpdateChartData(Rec, Period::Next);
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
        }
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
        if FinPerformChartMgt.UpdateChartData(Rec, Period) then
            Update(CurrPage.BusinessChart);
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
        CashFlowChartSetup: Record "Cash Flow Chart Setup";
        OldCashFlowChartSetup: Record "Cash Flow Chart Setup";
        CashFlowChartMgt: Codeunit "Cash Flow Chart Mgt.";
        StatusText: Text;
        NeedsUpdate: Boolean;
        NotSetupLbl: Label 'Cash Flow Forecast is not set up. An Assisted Setup is available for easy set up.';
        ChartDescriptionMsg: Label 'Shows the expected movement of money into or out of your company.';
        ConfirmRecalculationQst: Label 'You are about to update the information in the chart. This can take some time. Do you want to continue?';
        Period: Option " ",Next,Previous;
        [InDataSet]
        IsChartDataReady: Boolean;
        IsChartAddInReady: Boolean;
        IsCashFlowSetUp: Boolean;

}

