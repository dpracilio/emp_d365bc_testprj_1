page 50115 "Fin. Perform. Analysis Chart"
{
    Caption = 'Financial Performance';
    DeleteAllowed = false;
    PageType = CardPart;
    ShowFilter = false;
    SourceTable = "Business Chart Buffer";

    layout
    {
        area(content)
        {
            field(StatusText; 'General Ledger | View By Month')
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
                ApplicationArea = Basic, Suite;

                trigger AddInReady()
                begin
                    //CashFlowChartMgt.OnOpenPage(CashFlowChartSetup);
                    //UpdateStatus;
                    IsChartAddInReady := true;
                    if IsChartDataReady then
                        UpdateChart();
                end;

                trigger Refresh()
                begin
                    // NeedsUpdate := true;
                    If IsChartDataReady and IsChartDataReady then
                        UpdateChart();
                end;
            }
            // field(NotSetupLbl; NotSetupLbl)
            // {
            //     ApplicationArea = Basic, Suite;
            //     Editable = false;
            //     ShowCaption = false;
            //     Visible = NOT IsCashFlowSetUp;
            // }
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
                        ApplicationArea = Basic, Suite;
                        Caption = 'Day';
                        ToolTip = 'Each stack covers one day.';

                        trigger OnAction()
                        begin
                            CashFlowChartSetup.SetPeriodLength(CashFlowChartSetup."Period Length"::Day);
                            UpdateStatus;
                        end;
                    }
                    action(Week)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Week';
                        ToolTip = 'Show forecast entries summed for one week.';

                        trigger OnAction()
                        begin
                            CashFlowChartSetup.SetPeriodLength(CashFlowChartSetup."Period Length"::Week);
                            UpdateStatus;
                        end;
                    }
                    action(Month)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Month';
                        ToolTip = 'Each stack except for the last stack covers one month. The last stack contains data from the start of the month until the date that is defined by the Show option.';

                        trigger OnAction()
                        begin
                            CashFlowChartSetup.SetPeriodLength(CashFlowChartSetup."Period Length"::Month);
                            UpdateStatus;
                        end;
                    }
                    action(Quarter)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Quarter';
                        ToolTip = 'Each stack except for the last stack covers one quarter. The last stack contains data from the start of the quarter until the date that is defined by the Show option.';

                        trigger OnAction()
                        begin
                            CashFlowChartSetup.SetPeriodLength(CashFlowChartSetup."Period Length"::Quarter);
                            UpdateStatus;
                        end;
                    }
                    action(Year)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Year';
                        ToolTip = 'Show pending payments summed for one year. Overdue payments are shown as amounts within specific years from the due date going back five years from today''s date.';

                        trigger OnAction()
                        begin
                            CashFlowChartSetup.SetPeriodLength(CashFlowChartSetup."Period Length"::Year);
                            UpdateStatus;
                        end;
                    }
                }
            }
            action(ChartInformation)
            {
                ApplicationArea = Basic, Suite;
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

    trigger OnFindRecord(Which: Text): Boolean
    begin
        UpdateChart;
        IsChartDataReady := true;
        // if not IsCashFlowSetUp then
        //     exit(true);
    end;

    // trigger OnInit()
    // begin
    //     IsCashFlowSetUp := CashFlowForecastSetupExists;
    // end;

    local procedure UpdateChart()
    begin
        // if not NeedsUpdate then
        //     exit;
        // if not IsChartAddInReady then
        //     exit;
        // if not IsCashFlowSetUp then
        //     exit;

        // if CashFlowChartMgt.UpdateData(Rec) then
        FinPerformChartMgt.UpdateChartData(Rec);
        Update(CurrPage.BusinessChart);
        //UpdateStatus;

        //NeedsUpdate := false;
    end;

    local procedure UpdateStatus()
    begin
        NeedsUpdate := NeedsUpdate or IsSetupChanged;
        if not NeedsUpdate then
            exit;

        //OldCashFlowChartSetup := CashFlowChartSetup;
        //StatusText := CashFlowChartSetup.GetCurrentSelectionText;
    end;

    local procedure IsSetupChanged(): Boolean
    begin
        exit(
          (OldCashFlowChartSetup."Period Length" <> CashFlowChartSetup."Period Length") or
          (OldCashFlowChartSetup.Show <> CashFlowChartSetup.Show) or
          (OldCashFlowChartSetup."Start Date" <> CashFlowChartSetup."Start Date") or
          (OldCashFlowChartSetup."Group By" <> CashFlowChartSetup."Group By"));
    end;

    local procedure CashFlowForecastSetupExists(): Boolean
    var
        CashFlowSetup: Record "Cash Flow Setup";
    begin
        if not CashFlowSetup.Get then
            exit(false);
        exit(CashFlowSetup."CF No. on Chart in Role Center" <> '');
    end;

    local procedure RecalculateAndUpdateChart()
    var
        CashFlowSetup: Record "Cash Flow Setup";
        CashFlowManagement: Codeunit "Cash Flow Management";
    begin
        if not Confirm(ConfirmRecalculationQst) then
            exit;
        CashFlowSetup.Get;
        CashFlowManagement.UpdateCashFlowForecast(CashFlowSetup."Azure AI Enabled");
        CurrPage.Update(false);

        NeedsUpdate := true;
        UpdateStatus;
    end;

    var
        FinPerformChartMgt: Codeunit "Fin. Perform. Chart Mgmt";
        CashFlowChartSetup: Record "Cash Flow Chart Setup";
        OldCashFlowChartSetup: Record "Cash Flow Chart Setup";
        CashFlowChartMgt: Codeunit "Cash Flow Chart Mgt.";
        StatusText: Text;
        NeedsUpdate: Boolean;
        NotSetupLbl: Label 'Cash Flow Forecast is not set up. An Assisted Setup is available for easy set up.';
        ChartDescriptionMsg: Label 'Shows the expected movement of money into or out of your company.';
        ConfirmRecalculationQst: Label 'You are about to update the information in the chart. This can take some time. Do you want to continue?';
        [InDataSet]
        IsChartDataReady: Boolean;
        IsChartAddInReady: Boolean;
        IsCashFlowSetUp: Boolean;
}

