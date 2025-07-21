namespace Collier.Demo;

public record ClaimApprovalResponse
{
    public bool Approved { get; init; }
    public string? Reason { get; init; }
}
