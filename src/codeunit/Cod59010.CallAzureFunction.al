codeunit 59010 "Call Azure Function"
{
    local procedure MeaningOf(Stuff: Text) Result: Text;
    var
        Client: HttpClient;
        Content: HttpContent;
        Response: HttpResponseMessage;
    begin
        Content.WriteFrom(Stuff);
        Client.Post('https://d365bcapp02.azurewebsites.net/api/HttpTrigger1', Content, Response);
        Response.Content.ReadAs(Result)
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::LogInManagement, 'OnAfterCompanyOpen', '', true, true)]
    local procedure CompanyOpen()
    begin
        Message('Meaning of life, universe, and everything: %1', MeaningOf('Life'));
        Message('Meaning of five: %1', MeaningOf('five'));
    end;

}