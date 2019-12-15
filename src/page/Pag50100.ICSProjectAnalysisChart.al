page 50100 "ICS Project Analysis Chart"
{
    Caption = 'Project Analysis Chart';
    PageType = CardPart;
    SourceTable = "Business Chart Buffer";

    layout
    {
        area(Content)
        {
            field(ICSStatusTxt; StatusText)
            {
                ApplicationArea = All;
                Caption = 'Status Text';
                Editable = false;
                ShowCaption = false;
                ToolTip = 'Specifies the status of the chart';
            }
            usercontrol(BusinessChart; "Microsoft.Dynamics.Nav.Client.BusinessChart")
            {
                ApplicationArea = All;

                trigger DataPointClicked(point: JsonObject)
                begin
                    ICSProjChartMgt.ChartDrillDown(point, Department);
                end;

                trigger AddInReady()
                begin
                    IsChartAddInReady := true;

                    if IsChartAddInReady then
                        UpdateChart(0);
                end;

                trigger Refresh()
                begin
                    if IsChartAddInReady and IsChartDataReady then
                        UpdateChart(0);
                end;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction()
                begin

                end;
            }
        }
    }

    trigger OnFindRecord(Which: Text): Boolean
    begin
        UpdateChart(0);
        IsChartDataReady := true;
    end;

    trigger OnOpenPage()
    begin

    end;

    local procedure UpdateChart(MovePeriodP: Option " ",Next,Previous)
    begin
        if not IsChartDataReady then
            exit;
        if MovePeriodP = MovePeriodP::" " then
            ICSProjChartMgt.UpdateChartData(Rec, MovePeriod, PeriodLength::Year, Department, Year, YearP1, YearP2)
        else begin
            MovePeriod := MovePeriodP;
            ICSProjChartMgt.UpdateChartData(Rec, MovePeriod, PeriodLength::Year, Department, Year, YearP1, YearP2)
        end;
        Update(CurrPage.BusinessChart);
        StatusText := ICSProjChartMgt.GetStatusText(PeriodLength::Year, Department, Format(Year), Format(YearP1) + ' .. ' + Format(YearP2));
    end;

    var
        ICSProjChartMgt: Codeunit "ICS Project Chart Mgmt";
        StatusText: Text;

        [InDataSet]
        IsChartAddInReady: Boolean;
        IsChartDataReady: Boolean;
        MovePeriod: Option " ",Next,Previous;
        PeriodLength: Option Day,Week,Month,Quarter,Year;
        Department: Code[20];
        DepartmentG: Text;
        YearRangeG: Text;
        YearFilterG: Text;
        Year: Integer;
        YearP1: Integer;
        YearP2: Integer;
}