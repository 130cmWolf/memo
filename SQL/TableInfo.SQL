SELECT
    T.name AS [TableName],
    C.column_id AS [ColumnNo],
    C.name AS [ColumnName],
    CASE 
        WHEN TY.name IN ('binary','varbinary')
            THEN TY.name + '(' + 
                CASE
                    WHEN C.max_length = -1 
                        THEN 'max'
                    ELSE
                        CAST(C.max_length AS nvarchar(10))
                END + ')'
        WHEN TY.name IN ('nvarchar','nchar')
            THEN TY.name + '(' + 
                CASE
                    WHEN C.max_length = -1 
                        THEN 'max'
                    ELSE
                        CAST(C.max_length / 2 AS nvarchar(10))
                END + ')'
        WHEN TY.name IN ('decimal','numeric')
            THEN TY.name + '(' + 
                CAST(C.precision AS nvarchar(10)) + 
                CASE
                    WHEN C.scale = 0
                        THEN ''
                    ELSE
                        ',' + CAST(C.scale AS nvarchar(10))
                END + ')'
        ELSE
             TY.name
    END AS [Type],
    CASE C.is_nullable
        WHEN 1 THEN 'false'
        WHEN 0 THEN 'true'
    END AS [NOTNULL],
    CASE WHEN F.index_column_id IS NOT NULL AND E.is_primary_key = 1 
        THEN 'true'
        ELSE 'false'
    END AS [PrimaryKey],
    CASE WHEN C.is_identity =0 
        THEN 'false'
        ELSE 'true'
    END AS [AutoNumber],
    CASE WHEN C.default_object_id != 0
        THEN D.definition
    END AS [DefaultValue]
FROM
    sys.tables T
    INNER JOIN sys.columns C
        ON T.object_id = C.object_id
    INNER JOIN sys.types TY
        ON TY.user_type_id = C.user_type_id
    LEFT OUTER JOIN sys.default_constraints as D
        ON C.default_object_id = D.object_id
    LEFT OUTER JOIN sys.indexes AS E
        ON T.object_id = E.object_id
        AND E.is_primary_key = 1
    LEFT OUTER JOIN sys.index_columns AS F
        ON T.object_id = F.object_id
        AND C.column_id = F.column_id
ORDER BY
    T.name,C.column_id
