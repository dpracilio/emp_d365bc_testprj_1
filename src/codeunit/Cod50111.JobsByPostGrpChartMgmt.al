codeunit 50111 "Jobs By Post. Grp. Chart Mgmt"
{
    trigger OnRun()
    begin

    end;

    procedure UpdateChartData(var BusinessChartBuffer: Record "Business Chart Buffer")
    var
        ColumnIndex: Integer;
        JobPostGrp: Record "Job Posting Group";
        JobPostGrpCode: List of [Code[20]];
        JobPostGrpName: List of [Text];
        NoOfJobs: List of [Integer];
        NoOfActiveJobs: List of [Integer];
    begin
        with BusinessChartBuffer do begin
            Initialize();
            AddMeasure('No. of Jobs', 1, "Data Type"::Integer, "Chart Type"::Doughnut);
            SetXAxis('Job Posting Group', "Data Type"::String);
            CalcNoOfJobsPerPostGrp(JobPostGrpCode, JobPostGrpName, NoOfJobs);
            for ColumnIndex := 1 to NoOfJobs.Count do begin
                AddColumn(JobPostGrpName.Get(ColumnIndex));
                SetValue('No. of Jobs', ColumnIndex - 1, NoOfJobs.Get(ColumnIndex));
            end;
        end;
    end;

    procedure UpdateChartDataActiveJobs(var BusinessChartBuffer: Record "Business Chart Buffer"; var Point: JsonObject)
    var
        Measures: Text;
        XValueString: Text;
        JsonTokenMeasures: JsonToken;
        JsonTokenXValueString: JsonToken;

        ColumnIndex: Integer;
        JobPostGrp: Record "Job Posting Group";
        JobPostGrpCode: List of [Code[20]];
        JobPostGrpName: List of [Text];
        NoOfJobs: List of [Integer];
        NoOfActiveJobs: List of [Integer];
    begin
        // if Point.Get('Measures', JsonTokenMeasures) then begin
        //     Measures := Format(JsonTokenMeasures);
        //     Measures := DelChr(Measures, '=', '["]');
        // end;

        if Point.Get('XValueString', JsonTokenXValueString) then begin
            XValueString := Format(JsonTokenXValueString);
            XValueString := DelChr(XValueString, '=', '"');
        end;

        with BusinessChartBuffer do begin
            Initialize();
            AddMeasure('No. of Jobs', 1, "Data Type"::Integer, "Chart Type"::Column);
            SetXAxis('Job Posting Group', "Data Type"::String);
            CalcNoOfJobsPerPostGrp(JobPostGrpCode, JobPostGrpName, NoOfJobs);
            for ColumnIndex := 1 to NoOfJobs.Count do begin
                AddColumn(JobPostGrpName.Get(ColumnIndex));
                SetValue('No. of Jobs', ColumnIndex - 1, NoOfJobs.Get(ColumnIndex));
            end;
        end;
    end;

    procedure ChartDrillDown(var Point: JsonObject)
    var
        Job: Record Job;
        JobList: Page "Job List";
        Measures: Text;
        XValueString: Text;
        JsonTokenMeasures: JsonToken;
        JsonTokenXValueString: JsonToken;
    begin
        if Point.Get('Measures', JsonTokenMeasures) then begin
            Measures := Format(JsonTokenMeasures);
            Measures := DelChr(Measures, '=', '["]');
        end;
        if Point.Get('XValueString', JsonTokenXValueString) then begin
            XValueString := Format(JsonTokenXValueString);
            XValueString := DelChr(XValueString, '=', '"');
        end;

        Job.Reset();
        Job.FilterGroup(2);

        case Measures of
            'In Process':
                Job.SetRange("ICS Project Status", Job."ICS Project Status"::"In Process");
            'Open':
                Job.SetRange("ICS Project Status", Job."ICS Project Status"::Open);
            'Completed':
                Job.SetRange("ICS Project Status", Job."ICS Project Status"::Completed);
            'On Hold':
                Job.SetRange("ICS Project Status", Job."ICS Project Status"::"On Hold");
            'Planning':
                Job.SetRange("ICS Project Status", Job."ICS Project Status"::Planning);
        end;
        JobList.SetTableView(Job);
        Job.FilterGroup(0);
        JobList.RunModal();
    end;

    local procedure CalcNoOfJobsPerPostGrp(var JobPostGrpCode: List of [Code[20]]; var JobPostGrpName: List of [Text]; var NoOfJobs: List of [Integer])
    var
        Job: Record Job;
        JobPostGrp: Record "Job Posting Group";
    begin
        JobPostGrp.Reset();
        if JobPostGrp.FindFirst() then
            repeat
                Job.Reset();
                Job.SetRange("Job Posting Group", JobPostGrp.Code);

                if Job.Count <> 0 then begin
                    JobPostGrpName.Add(JobPostGrp.Description);
                    JobPostGrpCode.Add(JobPostGrp.Code);
                    NoOfJobs.Add(Job.Count);
                end;

            until JobPostGrp.Next() = 0;
    end;

    var
}