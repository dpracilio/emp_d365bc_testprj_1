page 50111 "Job Performance Chart Wrapper"
{
    Caption = 'Job Performance';
    PageType = CardPart;
    SourceTable = "Business Chart Buffer";
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            field(StatusTxt; 'Jobs by Posting Group')
            {
                ApplicationArea = All;
                Caption = 'Status Text';
                Editable = false;
                ShowCaption = false;
                Style = StrongAccent;
                StyleExpr = TRUE;
                ToolTip = 'Specifies the status of the chart';
            }
            usercontrol(BusinessChart; "Microsoft.Dynamics.Nav.Client.BusinessChart")
            {
                ApplicationArea = All;

                trigger DataPointClicked(point: JsonObject)
                var

                begin
                    if ActiveJobsShown then
                        JobsByPostGrpChartMgt.ChartDrillDown(point)
                    else begin
                        UpdateChartActiveJobs(point);
                        ActiveJobsShown := true;
                    end;
                end;

                trigger AddInReady()
                begin
                    IsChartAddInReady := true;

                    if IsChartAddInReady then
                        UpdateChart();
                end;

                trigger Refresh()
                begin
                    if IsChartAddInReady and IsChartDataReady then
                        UpdateChart();
                end;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Refresh)
            {
                ApplicationArea = All;
                Image = Refresh;
                ToolTip = 'Refresh Chart';

                trigger OnAction()
                begin
                    UpdateChart();
                end;
            }
        }
    }

    trigger OnFindRecord(Which: Text): Boolean
    begin
        UpdateChart;
        IsChartDataReady := true;
    end;

    trigger OnOpenPage()
    begin

    end;

    local procedure UpdateChart()
    begin
        if not IsChartDataReady then
            exit;
        JobsByPostGrpChartMgt.UpdateChartData(Rec);
        Update(CurrPage.BusinessChart);
        ActiveJobsShown := false;
    end;

    local procedure UpdateChartActiveJobs(var Point: JsonObject)
    var
        JobPostingGroupName: Variant;
        JobPostingGroup: Record "Job Posting Group";
    begin
        if not IsChartDataReady then
            exit;

        JobsByPostGrpChartMgt.UpdateChartDataActiveJobs(Rec, Point);
        Update(CurrPage.BusinessChart);
    end;

    var
        JobsByPostGrpChartMgt: Codeunit "Jobs By Post. Grp. Chart Mgmt";
        StatusText: Text;
        ActiveJobsShown: Boolean;

        [InDataSet]
        IsChartAddInReady: Boolean;
        IsChartDataReady: Boolean;
}