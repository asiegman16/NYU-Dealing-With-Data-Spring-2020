CREATE TABLE irs_agi_map (
    agi_map_id      INTEGER      PRIMARY KEY
                                 UNIQUE
                                 NOT NULL,
    agi_description VARCHAR (30) NOT NULL
);

CREATE TABLE irs_nyc_tax_returns (
    year         VARCHAR (4) NOT NULL,
    state        VARCHAR (2) NOT NULL,
    zipcode      VARCHAR (5) NOT NULL,
    agi_map_id   INTEGER     REFERENCES irs_agi_map (agi_map_id) 
                             NOT NULL,
    return_count INTEGER     NOT NULL,
    PRIMARY KEY (
        year,
        zipcode,
        agi_map_id
    )
);