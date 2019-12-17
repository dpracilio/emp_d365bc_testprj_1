codeunit 50111 "Jobs By Post. Grp. Chart Mgmt"
{
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
        NoOfJobs: Integer;
        JobPostGrp: Record "Job Posting Group";
        JobPostGrpCode: List of [Code[20]];
        JobPostGrpName: List of [Text];
        JobName: List of [Text];
        NoOfActiveJobs: List of [Integer];
        InvoicedAmount: List of [Decimal];
        CostAmount: List of [Decimal];
        RevenueAmount: List of [Decimal];
    begin
        if Point.Get('XValueString', JsonTokenXValueString) then begin
            XValueString := Format(JsonTokenXValueString);
            XValueString := DelChr(XValueString, '=', '"');
        end;

        JobPostGrp.SetRange(Description, XValueString);
        JobPostGrp.FindFirst();

        with BusinessChartBuffer do begin
            Initialize();
            AddMeasure('Cost', 1, "Data Type"::Decimal, "Chart Type"::StackedColumn);
            AddMeasure('Invoiced', 2, "Data Type"::Decimal, "Chart Type"::StackedColumn);
            AddMeasure('Revenue', 3, "Data Type"::Decimal, "Chart Type"::StackedColumn);
            SetXAxis('Job', "Data Type"::String);
            CalcJobAmounts(JobPostGrp, JobName, InvoicedAmount, CostAmount, RevenueAmount, NoOfJobs);
            for ColumnIndex := 1 to NoOfJobs do begin
                AddColumn(JobName.Get(ColumnIndex));
                SetValue('Cost', ColumnIndex - 1, CostAmount.Get(ColumnIndex));
                SetValue('Invoiced', ColumnIndex - 1, InvoicedAmount.Get(ColumnIndex));
                SetValue('Revenue', ColumnIndex - 1, RevenueAmount.Get(ColumnIndex));
            end;
        end;
    end;

    procedure ChartDrillDown(var Point: JsonObject)
    var
        Job: Record Job;
        JobLedgerEntry: Record "Job Ledger Entry";
        JobList: Page "Job List";
        JobLedgerEntries: Page "Job Ledger Entries";
        Measures: Text;
        XValueString: Text;
        JsonTokenMeasures: JsonToken;
        JsonTokenXValueString: JsonToken;
    begin
        if Point.Get('Measures', JsonTokenMeasures) then begin
            Measures := Format(JsonTokenMeasures);
            Measures := DelChr(Measures, '=', '["]');               // eg. Revenue
        end;
        if Point.Get('XValueString', JsonTokenXValueString) then begin
            XValueString := Format(JsonTokenXValueString);
            XValueString := DelChr(XValueString, '=', '"');         // eg. Arctic Art
        end;

        Clear(JobLedgerEntries);

        Job.Reset();
        Job.SetRange(Description, XValueString);
        Job.FindFirst();

        JobLedgerEntry.Reset();
        JobLedgerEntry.FilterGroup(2);
        JobLedgerEntry.SetCurrentKey("Job No.", "Entry Type", "Posting Date");
        JobLedgerEntry.SetRange("Job No.", Job."No.");
        JobLedgerEntries.SetTableView(JobLedgerEntry);
        JobLedgerEntry.FilterGroup(0);
        JobLedgerEntries.RunModal();
    end;

    local procedure CalcJobAmounts(var JobPostGrp: Record "Job Posting Group"; var JobName: List of [Text]; var InvoicedAmount: List of [Decimal]; var CostAmount: List of [Decimal]; var RevenueAmount: List of [Decimal]; var NoOfJobs: Integer)
    var
        Job: Record Job;
        JobLedgerEntry: Record "Job Ledger Entry";
        InvoicedAmountLCY: Decimal;
        CostAmountLCY: Decimal;
    begin
        Job.Reset();
        Job.SetRange("Job Posting Group", JobPostGrp.Code);
        Job.SetFilter(Status, '<>%1', Job.Status::Completed);
        Job.FindFirst();
        repeat
            Clear(InvoicedAmountLCY);
            Clear(CostAmountLCY);

            JobLedgerEntry.Reset();
            JobLedgerEntry.SetCurrentKey("Job No.", "Entry Type", "Posting Date");
            JobLedgerEntry.SetRange("Job No.", Job."No.");
            JobLedgerEntry.SetRange("Entry Type", JobLedgerEntry."Entry Type"::Sale);
            if JobLedgerEntry.FindFirst() then
                repeat
                    InvoicedAmountLCY := InvoicedAmountLCY + JobLedgerEntry."Line Amount (LCY)";
                until JobLedgerEntry.Next() = 0;

            JobLedgerEntry.Reset();
            JobLedgerEntry.SetCurrentKey("Job No.", "Entry Type", "Posting Date");
            JobLedgerEntry.SetRange("Job No.", Job."No.");
            JobLedgerEntry.SetRange("Entry Type", JobLedgerEntry."Entry Type"::Usage);
            if JobLedgerEntry.FindFirst() then
                repeat
                    CostAmountLCY := CostAmountLCY + JobLedgerEntry."Line Amount (LCY)";
                until JobLedgerEntry.Next() = 0;

            NoOfJobs := NoOfJobs + 1;
            JobName.Add(Job.Description);
            InvoicedAmount.Add(-InvoicedAmountLCY);
            CostAmount.Add(CostAmountLCY);
            RevenueAmount.Add(-InvoicedAmountLCY - CostAmountLCY);

        until Job.Next() = 0;
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
                Job.SetFilter(Status, '<>%1', Job.Status::Completed);

                if Job.Count <> 0 then begin
                    JobPostGrpName.Add(JobPostGrp.Description);
                    JobPostGrpCode.Add(JobPostGrp.Code);
                    NoOfJobs.Add(Job.Count);
                end;

            until JobPostGrp.Next() = 0;
    end;

    var
}