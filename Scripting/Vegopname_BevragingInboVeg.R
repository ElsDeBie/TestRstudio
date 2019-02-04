## opbouwen scripts voor inboveg-bevraging


library(knitr)
library(tidyverse)
library(DBI)

con <- dbConnect(odbc::odbc(), dsn = "Cydonia-prd") 


# Headerinfo

header_info <- function(RecordingGivid) {
  dbGetQuery(con,
             "SELECT 
             ivR.[RecordingGivid]
             , ivS.Name
             , ivR.UserReference
             , ivR.LocationCode
             , ivR.Latitude
             , ivR.Longitude
             , ivR.Area
             , ivR.Length
             , ivR.Width
             , ivR.SurveyId
             , coalesce(area, convert( nvarchar(20),ivR.Length * ivR.Width)) as B
             FROM [dbo].[ivRecording] ivR
             INNER JOIN [dbo].[ivSurvey] ivS on ivS.Id = ivR.SurveyId
             where ivR.NeedsWork = 0
             
             
             ;")
}

Vegopname_info <- function(RecordingGivid) {
  dbGetQuery(con,
    " SELECT 
    ivR.[RecordingGivid]
  , ivRL_Layer.LayerCode
  , ivRL_Layer.CoverCode
  , ivRL_Iden.TaxonFullText as OrignalName
  , ivRL_Iden.PhenologyCode
  , ivRL_Taxon.CoverageCode
  , ftCover.PctValue
  , ftAGL.Description as RecordingScale
  FROM [dbo].[ivRecording] ivR 
  LEFT JOIN [dbo].[ivRLLayer] ivRL_Layer on ivRL_Layer.RecordingID = ivR.Id
  LEFT JOIN [dbo].[ivRLTaxonOccurrence] ivRL_Taxon on ivRL_Taxon.LayerID = ivRL_Layer.ID
  LEFT JOIN [dbo].[ivRLIdentification] ivRL_Iden on ivRL_Iden.OccurrenceID = ivRL_Taxon.ID
  LEFT JOIN [dbo].[ivRLResources] ivRL_Res on ivRL_Res.ResourceGIVID = ivRL_Taxon.CoverageResource
  LEFT  JOIN [syno].[Futon_dbo_ftActionGroupList] ftAGL on ftAGL.ActionGroup = ivRL_Res.ActionGroup collate Latin1_General_CI_AI
  AND ftAGL.ListName = ivRL_Res.ListName collate Latin1_General_CI_AI
  LEFT JOIN [syno].[Futon_dbo_ftCoverValues] ftCover on ftCover.ListGIVID = ftAGL.ListGIVID
  AND ivRL_Taxon.CoverageCode = ftCover.Code collate Latin1_General_CI_AI
  WHERE ivR.NeedsWork = 0
  AND ivRL_Iden.Preferred = 1
                                ;")
}

##AND ivR.RecordingGivid = 'IV2016020113512239'
## Waarom deze onderstaande regel nodig? anders krijg je alle mogelijke coveragecodes, maar dat moet toch logischer op te lossen zijn?
## AND ivRL_Taxon.CoverageCode = ftCover.Code collate Latin1_General_CI_AI
## kan dus ook gewoon mee onder left joins geschreven worden, zie regel 17
