verboseRun({
  suppressPackageStartupMessages({
    library(RMINC)
    library(dplyr)
    library(lme4)
  })
  
  test_inside <- function(test, code, env = test_env()){
    test_that(test, eval(code, envir = env))
  }
  
  df <- read.csv("/hpf/largeprojects/MICe/dfernandes/lqiu_long/all_relative_jacobians/files.csv")
  df$files <- as.character(df$files)
  mask <- "/hpf/largeprojects/MICe/dfernandes/lqiu_long/test_p65dc2/mask/mask_dimorder_eroded.mnc"
  mask_vol <- mincGetVolume(mask)
  seg <-"/hpf/largeprojects/MICe/dfernandes/lqiu_long/relative_long_statistics/atlas/atlas_labels_resampled_dimorder_ops.mnc"
  defs <- "/hpf/largeprojects/MICe/tools/atlases/Dorr_2008_Steadman_2013_Ullmann_2013/Dorr_2008_Steadman_2013_Ullmann_2013_mapping_of_labels.csv" 
  
  test_that("MincLm works in parallel", {
    system.time(sMincLm <- mincLm(files ~ sex*age, data = df))
    system.time(pMincLm <- mincLm(files ~ sex*age, data = df, parallel = c("local", 2)))
    system.time(qMincLm <- mincLm(files ~ sex*age, data = df, parallel = c("pbs", 6)))
    
    expect_equal(sMincLm, pMincLm, check.attributes = FALSE)
    expect_equal(sMincLm, qMincLm, check.attributes = FALSE)
  })
  
  test_that("MincLmer works in parallel", {
    vslmer <- mincLmer(files~sex*age+(1|ID), parallel = c("pbs", 100), data=df, mask=mask)
    
    test_inds <- sample(which(mask_vol > .5), 20)
    test_coords <- lapply(test_inds, mincVectorToVoxelCoordinates, volumeFileName = mask)
    
    slow_fit <-
      lapply(test_coords, function(vox_coords){
        vox_data <- mincGetVoxel(df$files, vox_coords)
        lmod <- lmer(vox_data ~ sex*age+(1|ID), data = df)
        fixef(lmod)
      })  %>%
      simplify2array %>%
      t
    
    expect_equal(slow_fit, vslmer[test_inds, 1:4], check.attributes = FALSE)
  })
  
  anat_env <- new.env()
  test_inside("AnatGetAll works in parallel", {
    anat_frame <- 
      read.csv("/hpf/largeprojects/MICe/vousdend/osmopumps/documents/final_osmostic_pump_image_list.csv") %>%
      filter(Useable == 1)
    
    anat_files <- 
      system("ls /hpf/largeprojects/MICe/vousdend/osmopumps/registration/full_maget/08feb15_maget/*_no_nuc_no_inorm_lsq6/labels/*votedlabels.mnc"
             , intern = TRUE)
    
    aga <- anatGetAll2(anat_files, method = "labels"
                       , defs = "/hpf/largeprojects/MICe/tools/atlases/Dorr_2008/Dorr_2008_mapping_of_labels.csv")
    paga <- anatGetAll2(anat_files, method = "labels"
                        , defs = "/hpf/largeprojects/MICe/tools/atlases/Dorr_2008/Dorr_2008_mapping_of_labels.csv"
                        , parallel = c("local", 4))
    qaga <- anatGetAll2(anat_files, method = "labels"
                        , defs = "/hpf/largeprojects/MICe/tools/atlases/Dorr_2008/Dorr_2008_mapping_of_labels.csv"
                        , parallel = c("pbs", 6))
    
    expect_equal(aga, paga)
    expect_equal(aga, qaga)
  }, anat_env)
  
  test_inside("AnatLmer works in Parallel", {
    
    almer <- anatLmer(~ Dose + (1|Cage), data = anat_frame, anat = aga)
    palmer <- anatLmer(~ Dose + (1|Cage), data = anat_frame, anat = aga, parallel = c("local", 4))
    qalmer <- anatLmer(~ Dose + (1|Cage), data = anat_frame, anat = aga, parallel = c("", 6))
    
    expect_equal(almer, palmer)
    expect_equal(almer, qalmer)
  }, anat_env)
  
  
  test_that("VertexLmer Work in Parallel", {
    civet_example <- readLines("/hpf/largeprojects/MICe/chammill/POND/civetOutputs/pond20151123/idfile")
    thickness_df <-
      lapply(civet_example
             , civet.getFilenamesCorticalThickness
             , baseDir = "/hpf/largeprojects/MICe/chammill/POND/civetOutputs/pond20151123/"
             , civetVersion = "1.1.12") %>%
      bind_rows %>%
      mutate(random_dose = rnorm(nrow(.))
             , random_group = sample(1:2, nrow(.), replace = TRUE))
    
    random_mask <- numeric(40962)
    random_mask[sample(seq_len(40962), size = 200)] <- 1
    
    system.time(vlmer <- vertexLmer(left ~  random_dose + (1 | random_group)
                                    , data = thickness_df, mask = random_mask))
    system.time(pvlmer <- vertexLmer(left ~ random_dose + (1 | random_group)
                                     , data = thickness_df, parallel = c("local", 4)
                                     , mask = random_mask))
    qvlmer <- vertexLmer(left ~ random_dose + (1 | random_group)
                         , data = thickness_df, parallel = c("pbs", 2)
                         , mask = random_mask)
    
    expect_equal(vlmer, pvlmer, check.attributes = FALSE)
    expect_equal(vlmer, qvlmer, check.attributes = FALSE)
  })
  
  
})



