page 50111 "Jobs By Posting Group Chart"
{
    Caption = 'Jobs By Posting Group';
    PageType = CardPart;
    SourceTable = "Business Chart Buffer";

    layout
    {
        area(Content)
        {
            // field(ICSStatusTxt; StatusText)
            // {
            //     ApplicationArea = All;
            //     Caption = 'Status Text';
            //     Editable = false;
            //     ShowCaption = false;
            //     ToolTip = 'Specifies the status of the chart';
            // }
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
        Point2: JsonObject;
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