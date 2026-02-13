namespace InvoiceCopilotWebApp.Server.Model
{
    public class Document
    {
        /// <summary>
        /// Unique identifier for the document.
        /// </summary>
        public Guid DocumentId { get; init; }

        /// <summary>
        /// The owning tenant for this document.
        /// </summary>
        public Guid TenantId { get; init; }

        /// <summary>
        /// Gets or sets the URI of the associated blob resource.
        /// </summary>
        public required Uri BlobUri  { get; init; }

        /// <summary>
        /// The type of the document. See <see cref="DocumentType"/>.
        /// </summary>
        public DocumentType Type { get; init; }

        /// <summary>
        /// The processing status of the document. See <see cref="DocumentProcessingStatus"/>.
        /// </summary>
        public DocumentProcessingStatus Status { get; set; }

        /// <summary>
        /// Gets or sets the number of pages.
        /// </summary>
        public int Pages { get; init; }

        /// <summary>
        /// The size of the original document in bytes.
        /// </summary>
        public long SizeBytes { get; set; }

        /// <summary>
        /// Gets or sets the URI that identifies the location of the OCR/plaintext content.
        /// </summary>
        public Uri? TextUri { get; set; }

        /// <summary>
        /// Gets or sets the unique identifier of the user who uploaded the item.
        /// </summary>
        public Guid UploadedBy { get; set; }

        /// <summary>
        /// Gets or sets the date and time when the item was uploaded.
        /// </summary>
        public DateTimeOffset UploadedAt { get; init; }

        /// <summary>
        /// Gets or sets the hash value representing the contents of the file.
        /// </summary>
        public required string FileHash { get; init; }
    }

    public enum DocumentType
    {
        Invoice,
        Receipt,
        PurchaseOrder,
        Other
    }

    public enum DocumentProcessingStatus
    {
        Uploaded,
        Queued,
        Processing,
        Extracted,
        Failed
    }
}
